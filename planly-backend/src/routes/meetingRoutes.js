const express = require('express');
const router = express.Router();
const meetingController = require('../controllers/meetingController');
const authMiddleware = require('../middleware/authMiddleware');

// All meeting routes require authentication
router.use(authMiddleware);

router.get('/', meetingController.getMeetings);
router.get('/date/:date', meetingController.getMeetingsByDate);
router.get('/available-slots', meetingController.getAvailableSlots);
router.post('/', meetingController.createMeeting);
router.put('/:id', meetingController.updateMeeting);
router.patch('/:id/cancel', meetingController.cancelMeeting);
router.delete('/:id', meetingController.deleteMeeting);

module.exports = router;