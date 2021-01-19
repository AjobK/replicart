const jwt = require('jsonwebtoken');
require('dotenv').config()

const { JWT_SECRET } = process.env;

module.exports = (req, res, next) => {
    const { token } = req.cookies

    if (!token) {
        const error = new Error('Not authorized');
        error.statusCode = 401;
        throw error;
    }

    try{
        decodedToken = jwt.verify(token, JWT_SECRET);
    } catch (error){
        error.statusCode = 500;
        throw error;
    }

    req.decoded = decodedToken;

    // console.log('Passed isAuth')
    next();
};