const db = require('../database/db');

module.exports = class ReplicaDAO {
    static getReplicas() {
        return db.query('SELECT * FROM replica ORDER BY name');
    }

    static createReplica(body) {
        // Creates start question, tree and tree_version in DB
        const { artist, name, origin, cost, imageUrl, year } = body;

        return db.query('INSERT INTO replica (artist, name, origin, cost, image_url, year) VALUES ($1, $2, $3, $4, $5, $6);', [artist, name, origin, cost, imageUrl, year])
    }

    static updateReplicaById(body, id) {
        // Extract body data into constants
        const { artist, name, origin, year, cost, imageUrl } = body;

        if (!id) throw new InvalidIDError('No replica ID passed');

        console.log(body);

        return db.query(
            'UPDATE replica SET artist = $2, name = $3, origin = $4, year = $5, cost = $6, image_url = $7 WHERE id = $1;',
            [id, artist, name, origin, year, cost, imageUrl]
        );
    }

    static deleteReplicaById(id) {
        if (!id) throw new InvalidIDError('No replica ID passed');

        return db.query('DELETE FROM replica WHERE id=$1;', [id])
    }

    static getReplicaById(id) {
        return db.query('SELECT * FROM replica WHERE id=$1', [id]);
    }
}
