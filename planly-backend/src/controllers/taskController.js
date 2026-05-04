const pool = require('../config/database');

// Get all tasks for user
exports.getTasks = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT t.*, 
        COALESCE(
          json_agg(
            json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
          ) FILTER (WHERE s.id IS NOT NULL),
          '[]'
        ) as subtasks
       FROM tasks t
       LEFT JOIN subtasks s ON s.task_id = t.id
       WHERE t.user_id = $1
       GROUP BY t.id
       ORDER BY t.date DESC, t.start_time DESC NULLS LAST`,
      [req.userId]
    );

    res.json({ tasks: result.rows });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get tasks for specific date
exports.getTasksByDate = async (req, res) => {
  try {
    const { date } = req.params;

    const result = await pool.query(
      `SELECT t.*, 
        COALESCE(
          json_agg(
            json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
          ) FILTER (WHERE s.id IS NOT NULL),
          '[]'
        ) as subtasks
       FROM tasks t
       LEFT JOIN subtasks s ON s.task_id = t.id
       WHERE t.user_id = $1 AND t.date = $2
       GROUP BY t.id
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
      priority,
      category,
      projectId,
      subtasks,
    } = req.body;

    // Insert task
    const taskResult = await client.query(
      `INSERT INTO tasks (user_id, project_id, name, description, date, start_time, end_time, priority, category)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [req.userId, projectId || null, name, description || '', date, startTime, endTime, priority || 'medium', category || '']
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

    await client.query('COMMIT');

    // Fetch the complete task with subtasks
    const completeTask = await pool.query(
      `SELECT t.*, 
        COALESCE(
          json_agg(
            json_build_object('id', s.id, 'name', s.name, 'is_completed', s.is_completed)
          ) FILTER (WHERE s.id IS NOT NULL),
          '[]'
        ) as subtasks
       FROM tasks t
       LEFT JOIN subtasks s ON s.task_id = t.id
       WHERE t.id = $1
       GROUP BY t.id`,
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
  try {
    const { id } = req.params;
    const {
      name,
      description,
      date,
      startTime,
      endTime,
      priority,
      category,
      isCompleted,
    } = req.body;

    const result = await pool.query(
      `UPDATE tasks 
       SET name = $1, description = $2, date = $3, start_time = $4, 
           end_time = $5, priority = $6, category = $7, is_completed = $8,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $9 AND user_id = $10
       RETURNING *`,
      [name, description, date, startTime, endTime, priority, category, isCompleted, id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({
      message: 'Task updated successfully',
      task: result.rows[0],
    });
  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({ error: 'Server error' });
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