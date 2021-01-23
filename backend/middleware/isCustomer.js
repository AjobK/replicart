const AuthDAO = require('../dao/AuthDAO');

module.exports = async (req, res, next) => {
    if (!req.decoded || !req.decoded.id)
        res.status(422).send('No user id passed through request. Possibly forgot to add isAuth middleware to route.');

    let isCustomer = await AuthDAO.isRole('Customer', req.decoded.id);

    if (!isCustomer)
        res.status(401).send('Account does not have customer rights');
    else
        next();
};