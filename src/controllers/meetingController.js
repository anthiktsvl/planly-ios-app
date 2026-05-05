const pool = require('../config/database');

// Get all meetings
exports.getMeetings = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM meetings WHERE user_id = $1 ORDER BY date DESC, start_time DESC',
      [req.userId]
    );

    res.json({ meetings: result.rows });
  } catch (error) {
    console.error('Get meetings error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get meetings by date
exports.getMeetingsByDate = async (req, res) => {
  try {
    const { date } = req.params;

    const result = await pool.query(
      'SELECT * FROM meetings WHERE user_id = $1 AND date = $2 ORDER BY start_time',
      [req.userId, date]
    );

    res.json({ meetings: result.rows });
  } catch (error) {
    console.error('Get meetings by date error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create meeting
exports.createMeeting = async (req, res) => {
  try {
    const { title, description, date, startTime, endTime, attendeeEmail } = req.body;

    if (!title || !date || !startTime || !endTime || !attendeeEmail) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const result = await pool.query(
      `INSERT INTO meetings (user_id, title, description, date, start_time, end_time, attendee_email)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [req.userId, title, description || '', date, startTime, endTime, attendeeEmail]
    );

    res.status(201).json({
      message: 'Meeting created successfully',
      meeting: result.rows[0],
    });
  } catch (error) {
    console.error('Create meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update meeting
exports.updateMeeting = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, date, startTime, endTime, attendeeEmail, status } = req.body;

    const result = await pool.query(
      `UPDATE meetings 
       SET title = $1, description = $2, date = $3, start_time = $4, 
           end_time = $5, attendee_email = $6, status = $7, updated_at = CURRENT_TIMESTAMP
       WHERE id = $8 AND user_id = $9
       RETURNING *`,
      [title, description, date, startTime, endTime, attendeeEmail, status, id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Meeting not found' });
    }

    res.json({
      message: 'Meeting updated successfully',
      meeting: result.rows[0],
    });
  } catch (error) {
    console.error('Update meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Cancel meeting
exports.cancelMeeting = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE meetings 
       SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Meeting not found' });
    }

    res.json({
      message: 'Meeting cancelled successfully',
      meeting: result.rows[0],
    });
  } catch (error) {
    console.error('Cancel meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete meeting
exports.deleteMeeting = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM meetings WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Meeting not found' });
    }

    res.json({ message: 'Meeting deleted successfully' });
  } catch (error) {
    console.error('Delete meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get available time slots (simplified version)
exports.getAvailableSlots = async (req, res) => {
  try {
    const { attendeeEmail, startDate, endDate } = req.query;

    if (!attendeeEmail || !startDate || !endDate) {
      return res.status(400).json({ error: 'attendeeEmail, startDate, and endDate are required' });
    }

    // Get busy slots for the user
    const result = await pool.query(
      `SELECT date, start_time, end_time 
       FROM meetings 
       WHERE user_id = $1 
       AND date BETWEEN $2 AND $3
       AND status = 'scheduled'
       ORDER BY date, start_time`,
      [req.userId, startDate, endDate]
    );

    // In a real implementation, you would:
    // 1. Query the attendee's calendar too
    // 2. Calculate available slots based on both calendars
    // 3. Consider work hours
    // For now, we return the busy slots
    res.json({ busySlots: result.rows });
  } catch (error) {
    console.error('Get available slots error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};