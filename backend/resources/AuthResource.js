const express = require('express');
const { body } = require('express-validator');

const authController = require('../controllers/AuthController');
const isAuth = require('../middleware/is-auth');

const router = express.Router();

// GET /auth/users
router.get('/users', authController.getUsers);

// POST /auth/login
router.post('/login', authController.login);

// POST /auth/update
router.post('/update', authController.updateLastLogin);

router.post('/register', authController.register);

module.exports = router;
