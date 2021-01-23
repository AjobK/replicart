const express = require('express');

const basketItemController = require('../controllers/BasketItemController');
const isAuth = require('../middleware/isAuth');
const isCustomer = require('../middleware/isCustomer');

const router = express.Router();

// GET /api/replica
// Fetch all replicas
router.get('/', isAuth, isCustomer, basketItemController.getBasketItems);

router.post('/', isAuth, isCustomer, basketItemController.createBasketItem)

router.put('/', isAuth, isCustomer, basketItemController.updateBasketItem)

router.delete('/', isAuth, isCustomer, basketItemController.deleteBasketItems)

module.exports = router;