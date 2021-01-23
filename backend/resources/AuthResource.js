const express = require('express');

const authController = require('../controllers/AuthController');

const router = express.Router();

// POST /auth/login
router.post('/login', authController.login);

// GET /auth/logout
router.get('/logout', authController.logout);

// GET /auth/login-check
router.get('/login-check', authController.getLoggedIn);

router.post('/register', authController.register);

module.exports = router;
