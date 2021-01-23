const express = require('express');

const replicaController = require('../controllers/ReplicaController');
const isAdministrator = require('../middleware/isAdministrator');
const isAuth = require('../middleware/isAuth');

const router = express.Router();

// GET /api/replica
// Fetch all replicas
router.get('/', replicaController.getReplicas);

router.get('/:id', replicaController.getReplicaById);

router.delete('/:id', isAuth, isAdministrator, replicaController.deleteReplicaById)

router.put('/:id', isAuth, isAdministrator, replicaController.updateReplicaById)

router.post('/', isAuth, isAdministrator, replicaController.createReplica)

module.exports = router;