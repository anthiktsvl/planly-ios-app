const pool = require('../config/database');

// Get all users except current user
exports.getUsers = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, name, email
       FROM users
       WHERE id != $1
       ORDER BY name ASC`,
      [req.userId]
    );

    res.json({
      users: result.rows,
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};