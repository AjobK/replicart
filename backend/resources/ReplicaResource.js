const express = require('express');

const replicaController = require('../controllers/ReplicaController');
const isAuth = require('../middleware/is-auth');

const router = express.Router();

// GET /api/replica
// Fetch all replicas
router.get('/', /**isAuth,**/ replicaController.getReplicas);



module.exports = router;