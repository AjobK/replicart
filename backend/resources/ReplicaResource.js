const express = require('express');

const replicaController = require('../controllers/ReplicaController');
const isAuth = require('../middleware/isAuth');

const router = express.Router();

// GET /api/replica
// Fetch all replicas
router.get('/', replicaController.getReplicas);

router.delete('/:id', replicaController.deleteReplicaById)

module.exports = router;