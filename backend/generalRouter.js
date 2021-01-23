const router = require('express').Router();

// split up route handling
router.use('/replica', require('./resources/ReplicaResource'));
router.use('/auth', require('./resources/AuthResource'));
router.use('/order', require('./resources/OrderResource'));
router.use('/basket-item', require('./resources/BasketItemResource'));
// etc.

module.exports = router;