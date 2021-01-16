const ReplicaDAO = require('../dao/ReplicaDAO');

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

exports.getTrees = (req, res, next) => {
    Tree.getTrees(req.get('userID'))
    .then(trees => {
        res.status(200).json({
            message: 'Fetched trees successfully.',
            trees: trees.rows
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};

exports.getTreeById = (req, res, next) => {
    let user_id;
    let userID = req.get('userid');

    Tree.getTreeById(req.params.id)
    .then(trees => {
        console.log(req)
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

exports.createTree = (req, res, next) => {
    Tree.createTree(req.body)
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

exports.updateTree = (req, res, next) => {
    Tree.updateTree(req.body)
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

exports.deleteTreeById = (req, res, next) => {
    Tree.deleteTreeById(req.params.id)
        .then(() => {
            res.status(200).json({
                message: 'Deleted tree successfully.'
            })
        })
        .catch(err => {
            if (!err.statusCode) {
                err.statusCode = 500;
            }
            next(err);
        });
};
