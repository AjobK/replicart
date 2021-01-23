const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { decode } = require('punycode');
const AuthDAO = require('../dao/AuthDAO');

require('dotenv').config()

const { JWT_SECRET } = process.env;

exports.getLoggedIn = (req, res, next) => {
    let loggedIn = true;
    let decodedToken = ''

    const { token } = req.cookies

    if (!token) {
        loggedIn = false;
    } else {
        try {
            decodedToken = jwt.verify(token, JWT_SECRET);
        } catch (error) {
            loggedIn = false;
        }
    }

    AuthDAO.getAccountByUsername(decodedToken.username)
    .then(user => {
        if (!user.rows[0]) {
            res.status(200).json({
                loggedIn: false
            })
        } else {
            // Initial check whether user is logged in (On front-end app load)
            // Based on valid decodable token
            res.status(200).json({
                loggedIn: loggedIn,
                username: user.rows[0].username,
                roleName: user.rows[0].role_name
            });
        }
    })
}

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

    AuthDAO.getFullAccountByUsername(username)
    .then(user => {
        loadedUser = user.rows[0];

        if (!loadedUser) {
            const error = new Error('A user with this username does not exist.');
            error.statusCode = 401;
            throw error;
        }

        return bcrypt.compare(password, loadedUser.password);
    })
    .then(isEqual => {
        if(!isEqual){
            const error = new Error('Wrong password');
            error.statusCode = 401;

            throw error;
        }
        const token = jwt.sign(
            {
                id: loadedUser.id,
                username: loadedUser.username
            }, JWT_SECRET, {expiresIn: '1h'}
        ); //Generate token for client with an expire time of 1 hour.

        // Setting path to '/' so HTTP Cookie is retrievable across website
        res.setHeader('Set-Cookie', `token=${token}; HttpOnly; expires=${+new Date(new Date().getTime()+86409000).toUTCString()}; path=/`);
        res.status(200).json({
            loggedIn: true,
            username: loadedUser.username,
            roleName: loadedUser.role_name
        });
        res.send();
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next();
    });
}

exports.logout = (req, res, next) => {
    res.setHeader('Set-Cookie', `token=deleted; HttpOnly; expires=${Date.now()}; path=/`);
    res.status(200);
    res.send();
}

exports.register = async (req, res, next) => {
    const { body } = req;

    body.password = await bcrypt.hash(body.password, 12);

    AuthDAO.registerAccount(body)
    .then((data) => {
        const token = jwt.sign(
            {
                id: data.rows[0].id,
                username: body.username
            }, JWT_SECRET, {expiresIn: '1h'}
        ); //Generate token for client with an expire time of 1 hour.

        // Setting path to '/' so HTTP Cookie is retrievable across website
        res.setHeader('Set-Cookie', `token=${token}; HttpOnly; expires=${+new Date(new Date().getTime()+86409000).toUTCString()}; path=/`);
        res.status(200).json({
            message: 'Created user successfully.',
            loggedIn: true,
            username: body.username,
            roleName: 'Customer'
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
}
