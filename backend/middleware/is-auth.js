const jwt = require('jsonwebtoken');
require('dotenv').config()

const { JWT_SECRET } = process.env;

module.exports = (req, res, next) => {
    const authHeader = req.get('Authorization');
    if(!authHeader){
        const error = new Error('Not authorized');
        error.statusCode = 401;
        throw error;
    }
    const token = req.get('Authorization').split(' ')[1];
    let decodedToken;
    try{
        decodedToken = jwt.verify(token, JWT_SECRET);
    }catch(error){
        error.statusCode = 500;
        throw error;
    }
    if(!decodedToken){
        const error = new Error('Not authorized');
        error.statusCode = 401;
        throw error;
    }
    req.email = decodedToken.email;
    next();
};