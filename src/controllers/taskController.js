// 


const pool = require('../config/database');

// Get all tasks visible to user
exports.getTasks = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT t.*,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
              ORDER BY s.id
            )
            FROM subtasks s
            WHERE s.task_id = t.id
          ),
          '[]'
        ) as subtasks,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', u.id, 'name', u.name, 'email', u.email)
              ORDER BY u.name
            )
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as collaborators,
        COALESCE(
          (
            SELECT json_agg(u.email ORDER BY u.name)
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as assignees
       FROM tasks t
       WHERE t.user_id = $1
          OR EXISTS (
            SELECT 1
            FROM task_collaborators tc
            WHERE tc.task_id = t.id
              AND tc.user_id = $1
          )
       ORDER BY t.date DESC, t.start_time DESC NULLS LAST`,
      [req.userId]
    );

    res.json({ tasks: result.rows });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get tasks for specific date visible to user
exports.getTasksByDate = async (req, res) => {
  try {
    const { date } = req.params;

    const result = await pool.query(
      `SELECT t.*,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
              ORDER BY s.id
            )
            FROM subtasks s
            WHERE s.task_id = t.id
          ),
          '[]'
        ) as subtasks,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', u.id, 'name', u.name, 'email', u.email)
              ORDER BY u.name
            )
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as collaborators,
        COALESCE(
          (
            SELECT json_agg(u.email ORDER BY u.name)
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as assignees
       FROM tasks t
       WHERE (t.user_id = $1
          OR EXISTS (
            SELECT 1
            FROM task_collaborators tc
            WHERE tc.task_id = t.id
              AND tc.user_id = $1
          ))
         AND t.date = $2
       ORDER BY t.start_time NULLS LAST`,
      [req.userId, date]
    );

    res.json({ tasks: result.rows });
  } catch (error) {
    console.error('Get tasks by date error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create task
exports.createTask = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const {
      name,
      description,
      date,
      startTime,
      endTime,
      duration,
      priority,
      category,
      projectId,
      subtasks,
      collaboratorIds,
      assigneeEmails, // NEW: Accept assigneeEmails from iOS app
    } = req.body;

    // Insert task
    const taskResult = await client.query(
      `INSERT INTO tasks (user_id, project_id, name, description, date, start_time, end_time, duration, priority, category)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        req.userId,
        projectId || null,
        name,
        description || '',
        date,
        startTime,
        endTime,
        duration || null,
        priority || 'medium',
        category || '',
      ]
    );

    const task = taskResult.rows[0];

    // Insert subtasks if provided
    if (subtasks && subtasks.length > 0) {
      for (const subtask of subtasks) {
        await client.query(
          'INSERT INTO subtasks (task_id, name) VALUES ($1, $2)',
          [task.id, subtask.name]
        );
      }
    }

    // Insert collaborators by ID if provided
    if (collaboratorIds && collaboratorIds.length > 0) {
      for (const collaboratorId of collaboratorIds) {
        await client.query(
          `INSERT INTO task_collaborators (task_id, user_id)
           VALUES ($1, $2)
           ON CONFLICT (task_id, user_id) DO NOTHING`,
          [task.id, collaboratorId]
        );
      }
    }

    // NEW: Insert collaborators by email if provided (for iOS app)
    if (assigneeEmails && assigneeEmails.length > 0) {
      for (const email of assigneeEmails) {
        // Look up user ID from email
        const userResult = await client.query(
          'SELECT id FROM users WHERE email = $1',
          [email]
        );
        
        if (userResult.rows.length > 0) {
          const userId = userResult.rows[0].id;
          await client.query(
            `INSERT INTO task_collaborators (task_id, user_id)
             VALUES ($1, $2)
             ON CONFLICT (task_id, user_id) DO NOTHING`,
            [task.id, userId]
          );
        }
      }
    }

    await client.query('COMMIT');

    // Fetch the complete task with subtasks and collaborators
    const completeTask = await pool.query(
      `SELECT t.*,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
              ORDER BY s.id
            )
            FROM subtasks s
            WHERE s.task_id = t.id
          ),
          '[]'
        ) as subtasks,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', u.id, 'name', u.name, 'email', u.email)
              ORDER BY u.name
            )
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as collaborators,
        COALESCE(
          (
            SELECT json_agg(u.email ORDER BY u.name)
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as assignees
       FROM tasks t
       WHERE t.id = $1`,
      [task.id]
    );

    res.status(201).json({
      message: 'Task created successfully',
      task: completeTask.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create task error:', error);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
};

// Update task
exports.updateTask = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { id } = req.params;
    const {
      name,
      description,
      date,
      startTime,
      endTime,
      duration,
      priority,
      category,
      isCompleted,
      projectId,
      collaboratorIds,
      assigneeEmails, // NEW: Accept assigneeEmails from iOS app
    } = req.body;

    const existingTaskResult = await client.query(
      'SELECT * FROM tasks WHERE id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (existingTaskResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Task not found' });
    }

    const existingTask = existingTaskResult.rows[0];

    const result = await client.query(
      `UPDATE tasks
       SET name = $1,
           description = $2,
           date = $3,
           start_time = $4,
           end_time = $5,
           duration = $6,
           priority = $7,
           category = $8,
           is_completed = $9,
           project_id = $10,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $11 AND user_id = $12
       RETURNING *`,
      [
        name ?? existingTask.name,
        description ?? existingTask.description,
        date ?? existingTask.date,
        startTime ?? existingTask.start_time,
        endTime ?? existingTask.end_time,
        duration ?? existingTask.duration,
        priority ?? existingTask.priority,
        category ?? existingTask.category,
        isCompleted ?? existingTask.is_completed,
        projectId ?? existingTask.project_id,
        id,
        req.userId,
      ]
    );

    // Replace collaborators by ID if provided
    if (collaboratorIds !== undefined) {
      await client.query('DELETE FROM task_collaborators WHERE task_id = $1', [id]);

      if (collaboratorIds.length > 0) {
        for (const collaboratorId of collaboratorIds) {
          await client.query(
            `INSERT INTO task_collaborators (task_id, user_id)
             VALUES ($1, $2)
             ON CONFLICT (task_id, user_id) DO NOTHING`,
            [id, collaboratorId]
          );
        }
      }
    }

    // NEW: Replace collaborators by email if provided (for iOS app)
    if (assigneeEmails !== undefined) {
      await client.query('DELETE FROM task_collaborators WHERE task_id = $1', [id]);

      if (assigneeEmails.length > 0) {
        for (const email of assigneeEmails) {
          const userResult = await client.query(
            'SELECT id FROM users WHERE email = $1',
            [email]
          );
          
          if (userResult.rows.length > 0) {
            const userId = userResult.rows[0].id;
            await client.query(
              `INSERT INTO task_collaborators (task_id, user_id)
               VALUES ($1, $2)
               ON CONFLICT (task_id, user_id) DO NOTHING`,
              [id, userId]
            );
          }
        }
      }
    }

    await client.query('COMMIT');

    const updatedTask = await pool.query(
      `SELECT t.*,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
              ORDER BY s.id
            )
            FROM subtasks s
            WHERE s.task_id = t.id
          ),
          '[]'
        ) as subtasks,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object('id', u.id, 'name', u.name, 'email', u.email)
              ORDER BY u.name
            )
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as collaborators,
        COALESCE(
          (
            SELECT json_agg(u.email ORDER BY u.name)
            FROM task_collaborators tc
            JOIN users u ON u.id = tc.user_id
            WHERE tc.task_id = t.id
          ),
          '[]'
        ) as assignees
       FROM tasks t
       WHERE t.id = $1`,
      [id]
    );

    res.json({
      message: 'Task updated successfully',
      task: updatedTask.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Update task error:', error);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
};

// Delete task
exports.deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM tasks WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Toggle task completion
exports.toggleTaskCompletion = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE tasks
       SET is_completed = NOT is_completed, updated_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({
      message: 'Task completion toggled',
      task: result.rows[0],
    });
  } catch (error) {
    console.error('Toggle task error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};