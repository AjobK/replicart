const db = require('../database/db');

module.exports = class OrderDAO {
    static createOrderItems(body, decoded, order) {
        if (!decoded || !body) return false;
        if (!decoded.id) return false

        let dbQuery = '';

        body.orderItems.map((i) => {
            dbQuery += `INSERT INTO order_item (quantity, order_id, replica_id) VALUES (${i.amount}, ${order.id}, ${i.replica.id}); `
        });

        return db.query(dbQuery);
    }

    static createOrder(decoded) {
        return db.query(`INSERT INTO "order" (account_id) VALUES (${decoded.id}) RETURNING id;`)
    }

    static getOrders(decoded) {
        return db.query(`
            SELECT r.id, r.name, r.artist, r.origin, r.year, r.cost, r.image_url, oi.quantity, o.id AS order_id
            FROM order_item oi
            LEFT JOIN "replica" r ON oi.replica_id = r.id
            LEFT JOIN "order" o ON oi.order_id = o.id
            WHERE account_id = ${decoded.id}`
        );
    }
}
