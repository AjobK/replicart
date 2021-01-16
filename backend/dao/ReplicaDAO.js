const db = require('../database/db');

module.exports = class ReplicaDAO {
    static getReplicas() {
        return db.query('SELECT * FROM replica');
    }

    static getTrees(userID) {
        return db.query('SELECT tree_version.name AS title, tree_version.versionnumber AS version, tree.id, tree.start_question_id FROM tree LEFT JOIN tree_version ON tree.id = tree_version.id WHERE user_id = $1;', [userID]);
    }

    static async getTreeById(id) {
        return db.query('SELECT tree_version.name AS title, tree_version.versionnumber AS version, tree.id, tree.start_question_id, tree.user_id FROM tree LEFT JOIN tree_version ON tree.id = tree_version.id WHERE tree.id = $1;', [id]);
    }

    static createTree(body) {
        // Creates start question, tree and tree_version in DB
        const { startQuestionContent, treeName, userID } = body;

        return db.query('SELECT create_tree($1, $2, $3);', [startQuestionContent, treeName, userID])
    }

    static updateTree(body) {
        // Extract body data into constants
        const { id, name, startQuestionId } = body;

        if (!id) throw new InvalidIDError('No tree ID passed');

        if (!startQuestionId)
            return db.query('UPDATE tree_version SET name = $1 WHERE id = $2;', [name, id]);
        else
            return db.query(
                'UPDATE tree_version SET name = $1, startQuestionId = $2 WHERE id = $3;',
                [name, startQuestionId, id]
            );
    }

    static deleteTreeById(id) {
        if (!id) throw new InvalidIDError('No tree ID passed');

        return db.query('DELETE FROM tree WHERE id=$1;', [id]);
    }
}
