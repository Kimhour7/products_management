const Joi = require("joi");

function validateProduct(product) {
    const schema = Joi.object({
        productname: Joi.string().required(),
        price: Joi.number().required(),
        stock: Joi.number().required()
    });

    return schema.validate(product);
}

module.exports = validateProduct;