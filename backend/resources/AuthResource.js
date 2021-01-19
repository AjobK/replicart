const express = require('express');
const { body } = require('express-validator');

const authController = require('../controllers/AuthController');
const isAuth = require('../middleware/isAuth');

const router = express.Router();

// GET /auth/users
router.get('/users', isAuth, authController.getUsers);

// POST /auth/login
router.post('/login', authController.login);

// GET /auth/logout
router.get('/logout', authController.logout);

// GET /auth/login-check
router.get('/login-check', authController.getLoggedIn);

// POST /auth/update
router.post('/update', isAuth, authController.updateLastLogin);

router.post('/register', authController.register);

module.exports = router;
