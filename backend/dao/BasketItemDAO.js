const db = require('../database/db');

module.exports = class BasketItemDAO {
    static getBasketItems(accountId) {
        return db.query(`
            SELECT quantity, id, artist, name, origin, cost, image_url, year
            FROM basket_item
            LEFT JOIN replica ON replica.id = basket_item.replica_id
            WHERE account_id=$1
        `, [accountId]);
    }

    static async createBasketItem(accountId, body) {
        const { replicaId } = body;

        if (!replicaId) throw new Error('Replica ID missing or invalid');

        let alreadyExistingBasketItem = await db.query('SELECT * FROM basket_item WHERE account_id=$1 AND replica_id=$2;', [accountId, replicaId]);

        if (alreadyExistingBasketItem.rowCount >= 1)
            return db.query('UPDATE basket_item SET quantity=quantity+1 WHERE account_id=$1 AND replica_id=$2;', [accountId, replicaId])
        else
            return db.query('INSERT INTO basket_item (account_id, replica_id, quantity) VALUES ($1, $2, $3);', [accountId, replicaId, 1])
    }

    static changeBasketItemQuantity(accountId, body) {
        const { replicaId, quantity } = body;

        if (!replicaId) throw new Error('Replica ID missing or invalid');
        if (!quantity && quantity != 0) throw new Error('Quantity missing or invalid');

        if (quantity > 0)
            return db.query('UPDATE basket_item SET quantity=$3 WHERE account_id=$1 AND replica_id=$2;', [accountId, replicaId, quantity])
        else
            return this.deleteBasketItemByReplicaId(accountId, replicaId)

    }

    static deleteBasketItemByReplicaId(accountId, replicaId) {
        if (!accountId) throw new Error('Account ID missing or invalid');
        if (!replicaId) throw new Error('Replica ID missing or invalid');

        return db.query('DELETE FROM basket_item WHERE account_id=$1 AND replica_id=$2;', [accountId, replicaId])
    }

    static deleteBasketItems(accountId) {
        if (!accountId) throw new Error('Account ID missing or invalid');

        return db.query('DELETE FROM basket_item WHERE account_id=$1;', [accountId])
    }
}
