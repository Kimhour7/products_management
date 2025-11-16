const express = require("express");
const route = express.Router();

const productController = require("../controllers/productController");

route.get("/", productController.getAllProducts);
route.get("/:id", productController.getProductById);
route.post("/", productController.createProduct);
route.put("/:id", productController.updateProduct);
route.delete("/:id", productController.deleteProduct);

module.exports = route; 
