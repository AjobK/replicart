const BasketItemDAO = require('../dao/BasketItemDAO');

exports.getBasketItems = (req, res, next) =>  {
    if (!req.decoded || !req.decoded.id) throw Error('Invalid token data')

    BasketItemDAO.getBasketItems(req.decoded.id)
    .then(basketItems => {
        let formattedItems = basketItems.rows.map(i => {
            let imageUrl = i.image_url;
            let quantity = i.quantity;
            delete i.quantity;
            delete i.image_url;

            return { replica: {...i, imageUrl: imageUrl}, quantity: quantity }
        })

        res.status(200).json({
            message: 'Fetched basket items successfully.',
            basketItems: formattedItems
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }

        next(err);
    })
}

exports.createBasketItem = (req, res, next) => {
    BasketItemDAO.createBasketItem(req.decoded.id, req.body)
    .then(() => {
        res.status(200).json({
            message: 'Created basket item successfully.'
        })
    })
    .catch(err => {
        if (!err.statusCode)
            err.statusCode = 500;

        next(err);
    });
};

exports.updateBasketItem = (req, res, next) => {
    BasketItemDAO.changeBasketItemQuantity(req.decoded.id, req.body)
    .then(() => {
        res.status(200).json({
            message: 'Updated basket item successfully.'
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};

exports.deleteBasketItems = (req, res, next) => {
    BasketItemDAO.deleteBasketItems(req.decoded.id)
    .then(() => {
        res.status(200).json({
            message: 'Deleted basket items successfully.'
        })
    })
    .catch(err => {
        if (!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    });
};
