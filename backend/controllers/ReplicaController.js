const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const AuthDao = require('../dao/AuthDAO');
const ReplicaDAO = require('../dao/ReplicaDAO');

require('dotenv').config()

const { JWT_SECRET } = process.env;

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

exports.getReplicaById = (req, res, next) => {
    let user_id;
    let userID = req.get('userid');

    Replica.getReplicaById(req.params.id)
    .then(trees => {
        user_id = trees.rows[0].user_id;
        if(userID != user_id){
            const error = new Error('Not authorized');
            error.statusCode = 403;
            throw error;
        }
        return trees.rows[0];
    })
    .then(result => {
        res.status(200).json({
            message: 'Fetched tree successfully.',
            tree: result
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};

exports.createReplica = (req, res, next) => {
    Replica.createReplica(req.body)
    .then(tree => {
        res.status(200).json({
            message: 'Created tree successfully.',
            trees: tree.rows[0]
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};

exports.updateReplica = (req, res, next) => {
    Replica.updateReplica(req.body)
    .then(tree => {
        res.status(200).json({
            message: 'Updated tree successfully.',
            trees: tree.rows[0]
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};

exports.deleteReplicaById = (req, res, next) => {
    ReplicaDAO.deleteReplicaById(req.params.id)
    .then(() => {
        res.status(200).json({
            message: 'Deleted replica successfully.'
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};
