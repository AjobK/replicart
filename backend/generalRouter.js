const router = require('express').Router();

// split up route handling
router.use('/replica', require('./resources/ReplicaResource'));
router.use('/auth', require('./resources/AuthResource'));
router.use('/order', require('./resources/OrderResource'));
// etc.

module.exports = router;