const db = require('../database/db');
const { InvalidIDError } = require('../errors');

module.exports = class AuthDao {
    static getUsers(){
        return db.query(`SELECT username FROM account;`)
    }

    static getAccountByUsername(username){
        return db.query(`SELECT * FROM account WHERE username=$1`, [username]);
    }

    static updateAccountLastLogin(body){
        const { email } = body;

        return db.query('UPDATE account SET last_logged_in = $1 WHERE email=$2', [new Date(), email]);
    }

    static registerAccount(body) {
        const { username, password } = body;

        return db.query(
            'INSERT INTO account (username, password, role_id) ' +
            'VALUES ($1, $2, $3);',
            [username, password, 1]
        );
    }
}