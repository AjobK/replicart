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

exports.getReplicaById = (req, res, next) =>  {
    ReplicaDAO.getReplicaById(req.params.id)
    .then(replica => {
        res.status(200).json({
            message: 'Fetched replica successfully.',
            replica: replica.rows[0]
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }

        next(err);
    })
}

exports.createReplica = (req, res, next) => {
    ReplicaDAO.createReplica(req.body)
    .then(tree => {
        res.status(200).json({
            message: 'Created replica successfully.',
            trees: tree.rows[0]
        })
    })
    .catch(err => {
        if (!err.statusCode)
            err.statusCode = 500;

        next(err);
    });
};

exports.updateReplicaById = (req, res, next) => {
    ReplicaDAO.updateReplicaById(req.body, req.params.id)
    .then(tree => {
        res.status(200).json({
            message: 'Updated replica successfully.',
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
