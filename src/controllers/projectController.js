const pool = require('../config/database');

// Get all projects
exports.getProjects = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*, 
        COUNT(t.id) FILTER (WHERE t.is_completed = false) as incomplete_tasks,
        COUNT(t.id) FILTER (WHERE t.is_completed = true) as completed_tasks,
        COUNT(t.id) as total_tasks
       FROM projects p
       LEFT JOIN tasks t ON t.project_id = p.id
       WHERE p.user_id = $1
       GROUP BY p.id
       ORDER BY p.created_at DESC`,
      [req.userId]
    );

    res.json({ projects: result.rows });
  } catch (error) {
    console.error('Get projects error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get single project with tasks
exports.getProject = async (req, res) => {
  try {
    const { id } = req.params;

    const projectResult = await pool.query(
      'SELECT * FROM projects WHERE id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (projectResult.rows.length === 0) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const tasksResult = await pool.query(
      'SELECT * FROM tasks WHERE project_id = $1 ORDER BY date, start_time',
      [id]
    );

    res.json({
      project: projectResult.rows[0],
      tasks: tasksResult.rows,
    });
  } catch (error) {
    console.error('Get project error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create project
exports.createProject = async (req, res) => {
  try {
    const { name, description, estimatedHours, deadline, category, color } = req.body;

    if (!name || !estimatedHours) {
      return res.status(400).json({ error: 'Name and estimated hours are required' });
    }

    const result = await pool.query(
      `INSERT INTO projects (user_id, name, description, estimated_hours, deadline, category, color)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [req.userId, name, description || '', estimatedHours, deadline, category || '', color || '#FFD6E8']
    );

    res.status(201).json({
      message: 'Project created successfully',
      project: result.rows[0],
    });
  } catch (error) {
    console.error('Create project error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update project
exports.updateProject = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, estimatedHours, deadline, category, color } = req.body;

    const result = await pool.query(
      `UPDATE projects 
       SET name = $1, description = $2, estimated_hours = $3, deadline = $4, 
           category = $5, color = $6, updated_at = CURRENT_TIMESTAMP
       WHERE id = $7 AND user_id = $8
       RETURNING *`,
      [name, description, estimatedHours, deadline, category, color, id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Project not found' });
    }

    res.json({
      message: 'Project updated successfully',
      project: result.rows[0],
    });
  } catch (error) {
    console.error('Update project error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete project
exports.deleteProject = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM projects WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Project not found' });
    }

    res.json({ message: 'Project deleted successfully' });
  } catch (error) {
    console.error('Delete project error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};