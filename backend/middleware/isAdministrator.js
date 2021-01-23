const AuthDAO = require('../dao/AuthDAO');

module.exports = async (req, res, next) => {
    if (!req.decoded || !req.decoded.id)
        res.status(422).send('No user id passed through request. Possibly forgot to add isAuth middleware to route.');

    let isAdmin = await AuthDAO.isRole('Administrator', req.decoded.id);

    if (!isAdmin)
        res.status(401).send('Account does not have administrative rights');
    else
        next();
};