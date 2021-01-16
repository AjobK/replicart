const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const AuthDAO = require('../dao/AuthDAO');

require('dotenv').config()

const { JWT_SECRET } = process.env;

exports.getUsers = (req, res, next) => {
    AuthDAO.getUsers()
    .then(users => {
        res.status(200).json({
            message: 'Fetched users successfully',
            users: users
        })
    })
    .catch(err => {
        if (!err.statusCode()) {
            err.statusCode = 500;
        }
        next(err);
    });
}

exports.login = (req, res, next) => {
    const { username, password } = req.body;
    let loadedUser;

    AuthDAO.getAccountByUsername(username)
    .then(user => {
        if (!user) {
            const error = new Error('A user with this username does not exist.');
            error.statusCode = 401;
            throw error;
        }
        loadedUser = user.rows[0];
        return bcrypt.compare(password, loadedUser.password);
    })
    .then(isEqual => {
        if(!isEqual){
            const error = new Error('Wrong password');
            error.statusCode = 401;
            throw error;
        }
        const token = jwt.sign({username: loadedUser.username}, JWT_SECRET, {expiresIn: '1h'}); //Generate token for client with an expire time of 1 hour.

        res.status(200).json({
            id: loadedUser.id,
            token: token,
            username: loadedUser.username
        });
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
}

exports.updateLastLogin = (req, res, next) => {
    AuthDAO.updateAccountLastLogin(req.body)
        .then(() => {
            res.status(200).json({
                message: 'Updated user last login date!'
            });
        })
        .catch(err => {
            if (!err.statusCode) {
                err.statusCode = 500;
            }
            next(err);
        });
}

exports.register = async (req, res, next) => {
    const { body } = req;

    body.password = await bcrypt.hash(body.password, 12);

    AuthDAO.registerAccount(body)
    .then(() => {
        res.status(200).json({
            message: 'Created user successfully.'
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
}
