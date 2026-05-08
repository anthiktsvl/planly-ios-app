const pool = require('../config/database');

exports.getMeetings = async (req, res) => {
  try {
    const userResult = await pool.query(
      'SELECT email FROM users WHERE id = $1',
      [req.userId]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userEmail = userResult.rows[0].email;
    
    // Get meetings where user is the creator OR an attendee
    const result = await pool.query(
      `SELECT DISTINCT m.* 
       FROM meetings m
       LEFT JOIN meeting_attendees ma ON m.id = ma.meeting_id
       WHERE m.user_id = $1 OR ma.attendee_email = $2
       ORDER BY m.date DESC, m.start_time DESC`,
      [req.userId, userEmail]
    );

    // For each meeting, get its attendees
    const meetingsWithAttendees = await Promise.all(
      result.rows.map(async (meeting) => {
        const attendeesResult = await pool.query(
          'SELECT attendee_email FROM meeting_attendees WHERE meeting_id = $1',
          [meeting.id]
        );
        
        return {
          ...meeting,
          attendees: attendeesResult.rows.map(row => row.attendee_email)
        };
      })
    );

    res.json({ meetings: meetingsWithAttendees });
  } catch (error) {
    console.error('Get meetings error:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create meeting with multiple attendees
exports.createMeeting = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { title, description, date, startTime, endTime, attendeeEmails, meetingLink } = req.body;

    if (!title || !date || !startTime || !endTime || !attendeeEmails || attendeeEmails.length === 0) {
      return res.status(400).json({ error: 'All fields are required, including at least one attendee' });
    }

    await client.query('BEGIN');

    // Insert meeting WITHOUT attendee_email column
    const meetingResult = await client.query(
      `INSERT INTO meetings (user_id, title, description, date, start_time, end_time, meeting_link, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'scheduled')
       RETURNING *`,
      [req.userId, title, description || '', date, startTime, endTime, meetingLink || null]
    );

    const meeting = meetingResult.rows[0];

    // Insert attendees into meeting_attendees table
    for (const email of attendeeEmails) {
      await client.query(
        'INSERT INTO meeting_attendees (meeting_id, attendee_email) VALUES ($1, $2)',
        [meeting.id, email]
      );
    }

    await client.query('COMMIT');

    // Get attendees for response
    const attendeesResult = await client.query(
      'SELECT attendee_email FROM meeting_attendees WHERE meeting_id = $1',
      [meeting.id]
    );

    res.status(201).json({
      message: 'Meeting created successfully',
      meeting: {
        ...meeting,
        attendees: attendeesResult.rows.map(row => row.attendee_email)
      },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
};

// Update meeting with multiple attendees
exports.updateMeeting = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { id } = req.params;
    const { title, description, date, startTime, endTime, attendeeEmails, status, meetingLink } = req.body;

    await client.query('BEGIN');

    const result = await client.query(
      `UPDATE meetings 
       SET title = $1, description = $2, date = $3, start_time = $4, 
           end_time = $5, status = $6, meeting_link = $7, updated_at = CURRENT_TIMESTAMP
       WHERE id = $8 AND user_id = $9
       RETURNING *`,
      [title, description, date, startTime, endTime, status, meetingLink, id, req.userId]
    );

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Meeting not found' });
    }

    // Delete old attendees and insert new ones
    await client.query('DELETE FROM meeting_attendees WHERE meeting_id = $1', [id]);
    
    for (const email of attendeeEmails) {
      await client.query(
        'INSERT INTO meeting_attendees (meeting_id, attendee_email) VALUES ($1, $2)',
        [id, email]
      );
    }

    await client.query('COMMIT');

    // Get attendees for response
    const attendeesResult = await client.query(
      'SELECT attendee_email FROM meeting_attendees WHERE meeting_id = $1',
      [id]
    );

    res.json({
      message: 'Meeting updated successfully',
      meeting: {
        ...result.rows[0],
        attendees: attendeesResult.rows.map(row => row.attendee_email)
      },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Update meeting error:', error);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
};

// Get meetings by date
exports.getMeetingsByDate = async (req, res) => {
  try {
    const { date } = req.params;
    
    const userResult = await pool.query(
      'SELECT email FROM users WHERE id = $1',
      [req.userId]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userEmail = userResult.rows[0].email;

    const result = await pool.query(
      `SELECT DISTINCT m.* 
       FROM meetings m
       LEFT JOIN meeting_attendees ma ON m.id = ma.meeting_id
       WHERE (m.user_id = $1 OR ma.attendee_email = $2) AND m.date = $3 
       ORDER BY m.start_time`,
      [req.userId, userEmail, date]
    );

    // For each meeting, get its attendees
    const meetingsWithAttendees = await Promise.all(
      result.rows.map(async (meeting) => {
        const attendeesResult = await pool.query(
          'SELECT attendee_email FROM meeting_attendees WHERE meeting_id = $1',
          [meeting.id]
        );
        
        return {
          ...meeting,
          attendees: attendeesResult.rows.map(row => row.attendee_email)
        };
      })
    );

    res.json({ meetings: meetingsWithAttendees });
  } catch (error) {
    console.error('Get meetings by date error:', error);
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