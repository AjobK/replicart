const db = require('../database/db');

module.exports = class AuthDAO {
    static getAccountByUsername(username){
        return db.query(`SELECT username, role.name AS role_name FROM account LEFT JOIN role ON role_id = role.id WHERE username=$1`, [username]);
    }

    static getFullAccountByUsername(username){
        return db.query(`SELECT account.id, username, role.name AS role_name, password FROM account LEFT JOIN role ON role_id = role.id WHERE username=$1`, [username]);
    }

    static updateAccountLastLogin(body){
        const { email } = body;

        return db.query('UPDATE account SET last_logged_in = $1 WHERE email=$2', [new Date(), email]);
    }

    static registerAccount(body) {
        const { username, password } = body;

        return db.query(
            'INSERT INTO account (username, password, role_id) ' +
            'VALUES ($1, $2, $3) RETURNING id;',
            [username, password, 1]
        );
    }

    static async isRole(roleName, accountId) {
        let isAdmin = await db.query(
            'SELECT role.name FROM account LEFT JOIN role ON role.id = account.role_id WHERE account.id=$1;', [accountId]
        )

        return isAdmin.rows[0].name === roleName
    }
}