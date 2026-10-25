/**
 * MongoDB Index Creation Script
 * Database: skillcommerce_catalog
 * Execution: mongosh "mongodb://localhost:27017/skillcommerce_catalog" create_indexes.js
 */

const db = db.getSiblingDB("skillcommerce_catalog");

print("Creating indexes on collection: products...");
db.products.createIndex({ "sku": 1 }, { unique: true, name: "uq_products_sku" });
db.products.createIndex({ "slug": 1 }, { unique: true, name: "uq_products_slug" });
db.products.createIndex({ "category": 1, "isActive": 1, "price.amount": 1 }, { name: "ix_products_cat_active_price" });
db.products.createIndex({ "isPreOrder": 1, "isActive": 1 }, { name: "ix_products_preorder_active" });
db.products.createIndex(
  {
    "title": "text",
    "brand": "text",
    "compatibility": "text"
  },
  {
    name: "txt_products_search",
    weights: {
      "title": 10,
      "brand": 5,
      "compatibility": 3
    },
    default_language: "none"
  }
);

print("Creating indexes on collection: provider_portfolios...");
db.provider_portfolios.createIndex({ "providerId": 1 }, { unique: true, name: "uq_portfolios_provider_id" });

print("Creating indexes on collection: reviews...");
db.reviews.createIndex({ "bookingId": 1 }, { unique: true, name: "uq_reviews_booking_id" });
db.reviews.createIndex({ "providerId": 1, "createdAt": -1 }, { name: "ix_reviews_provider_created" });
db.reviews.createIndex({ "customerId": 1, "createdAt": -1 }, { name: "ix_reviews_customer_created" });

print("All MongoDB indexes established successfully.");
