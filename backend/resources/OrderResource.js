const express = require('express');

const orderController = require('../controllers/OrderController');
const isAuth = require('../middleware/isAuth');
const isCustomer = require('../middleware/isCustomer');

const router = express.Router();

// GET /auth/users
router.post('/', isAuth, isCustomer, orderController.orderReplicas);

router.get('/', isAuth, isCustomer, orderController.getOrders);

module.exports = router;
