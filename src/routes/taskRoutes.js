const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');

// All task routes require authentication
router.use(authMiddleware);

router.get('/', taskController.getTasks);
router.get('/date/:date', taskController.getTasksByDate);
router.post('/', taskController.createTask);
router.put('/:id', taskController.updateTask);
router.delete('/:id', taskController.deleteTask);
router.patch('/:id/toggle', taskController.toggleTaskCompletion);

module.exports = router;