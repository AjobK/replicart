const express = require('express');
const { body } = require('express-validator');

const orderController = require('../controllers/OrderController');
const isAuth = require('../middleware/isAuth');

const router = express.Router();

// GET /auth/users
router.post('/', isAuth, orderController.orderReplicas);

router.get('/', isAuth, orderController.getOrders);

module.exports = router;
