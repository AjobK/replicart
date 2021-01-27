const ReplicaDAO = require('../dao/ReplicaDAO');
const isNumeric = require('validator/lib/isNumeric')
const isURL = require('validator/lib/isURL')

exports.getReplicas = (req, res, next) =>  {
    ReplicaDAO.getReplicas()
    .then(replicas => {
        res.status(200).json({
            message: 'Fetched replicas successfully.',
            replicas: replicas.rows
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }

        next(err);
    })
}

exports.getReplicaById = (req, res, next) =>  {
    ReplicaDAO.getReplicaById(req.params.id)
    .then(replica => {
        res.status(200).json({
            message: 'Fetched replica successfully.',
            replica: replica.rows[0]
        })
    })
    .catch(() => {
        res.status(404).json({
            message: 'Could not find replica by given ID'
        });
    })
}

exports.createReplica = (req, res, next) => {
    if (!req.body.imageUrl || !isURL(req.body.imageUrl)) return res.status(422).json({ message: 'Invalud replica URL '})

    ReplicaDAO.createReplica(req.body)
    .then(replica => {
        res.status(200).json({
            message: 'Created replica successfully.',
            replicas: replica.rows[0]
        });
    })
    .catch(() => {
        res.status(422).json({
            message: 'Could not create replica'
        });
    });
};

exports.updateReplicaById = (req, res, next) => {
    if (!req.body.imageUrl || !isURL(req.body.imageUrl)) return res.status(422).json({ message: 'Invalud replica URL '})
    if (!req.params.id) return res.status(422).json({ message: 'Invalid replica ID '})

    ReplicaDAO.updateReplicaById(req.body, req.params.id)
    .then(() => {
        res.status(200).json({
            message: 'Updated replica successfully.',
        })
    })
    .catch(() => {
        res.status(422).json({
            message: 'Could not update replica'
        });
    });
};

exports.deleteReplicaById = (req, res, next) => {
    if (!req.params.id || !isNumeric(req.params.id)) res.status(500).json({ message: 'Invalid replica ID' });

    ReplicaDAO.deleteReplicaById(req.params.id)
    .then(() => {
        res.status(200).json({
            message: 'Deleted replica successfully.'
        })
    })
    .catch(() => {
        res.status(422).json({
            message: 'Could not delete replica'
        });
    });
};
