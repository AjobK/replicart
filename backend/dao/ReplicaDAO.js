const db = require('../database/db');
const escape = require('validator/lib/escape')
const isURL = require('validator/lib/isURL')

module.exports = class ReplicaDAO {
    static getReplicas() {
        return db.query('SELECT * FROM replica ORDER BY name');
    }

    static createReplica(body) {
        // Escapes everything besides URL
        Object.keys(body).map(key => { if (key != 'imageUrl' && typeof body[key] == 'string') body[key] = escape(body[key]) })

        const { artist, name, origin, cost, imageUrl, year } = body;

        return db.query(
            'INSERT INTO replica (artist, name, origin, cost, year, image_url) VALUES ($1, $2, $3, $4, $5, $6);',
            [artist, name, origin, cost, year, imageUrl]
        )
    }

    static updateReplicaById(body, id) {
        // Escapes everything besides URL
        Object.keys(body).map(key => { if (key != 'imageUrl' && typeof body[key] == 'string') body[key] = escape(body[key]) })

        const { artist, name, origin, year, cost, imageUrl } = body;

        return db.query(
            'UPDATE replica SET artist = $2, name = $3, origin = $4, year = $5, cost = $6, image_url = $7 WHERE id = $1;',
            [id, artist, name, origin, year, cost, imageUrl]
        );
    }

    static deleteReplicaById(id) {
        // Escape not needed, DB errors if invalid type
        return db.query('DELETE FROM replica WHERE id=$1;', [id])
    }

    static getReplicaById(id) {
        // Escape not needed, DB errors if invalid type
        return db.query('SELECT * FROM replica WHERE id=$1', [id]);
    }
}
