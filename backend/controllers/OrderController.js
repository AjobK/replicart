const OrderDAO = require('../dao/OrderDAO');

exports.orderReplicas = (req, res, next) =>  {
    OrderDAO.createOrder(req.decoded)
    .then(order => {
        OrderDAO.createOrderItems(req.body, req.decoded, order.rows[0])
        .then(() => {
            res.status(200).json({
                message: 'Ordered replicas succesfully.'
            })
        })
        .catch(err => {
            if (!err.statusCode) {
                err.statusCode = 500;
            }
    
            next(err);
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }

        next(err);
    })
}

exports.getOrders = (req, res, next) =>  {
    OrderDAO.getOrders(req.decoded)
    .then(orders => {
        let returnOrders = {}

        orders.rows.map((orderItem) => {
            if (returnOrders[orderItem.order_id])
                returnOrders[orderItem.order_id].push(orderItem);
            else
                returnOrders[orderItem.order_id] = [orderItem];
        })

        return returnOrders
    })
    .then(orderItems => {
        res.status(200).json({
            message: 'Orders sent succesfully.',
            orders: orderItems
        })
    });
}
