const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all user routes
router.use(authMiddleware);

// GET /api/users
router.get('/', userController.getUsers);

module.exports = router;

