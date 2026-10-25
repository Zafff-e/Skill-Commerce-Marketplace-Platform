/**
 * MongoDB Index Creation Script
 * Database: skillcommerce_catalog
 * Execution: mongosh "mongodb://localhost:27017/skillcommerce_catalog" create_indexes.js
 */

const catalogDb = db.getSiblingDB("skillcommerce_catalog");

print("Creating indexes on collection: products...");
catalogDb.products.createIndex({ "sku": 1 }, { unique: true, name: "uq_products_sku" });
catalogDb.products.createIndex({ "slug": 1 }, { unique: true, name: "uq_products_slug" });
catalogDb.products.createIndex({ "variants.variantSku": 1 }, { name: "ix_products_variants_sku", sparse: true });
catalogDb.products.createIndex({ "category": 1, "isActive": 1, "price.amount": 1 }, { name: "ix_products_cat_active_price" });
catalogDb.products.createIndex({ "isPreOrder": 1, "isActive": 1 }, { name: "ix_products_preorder_active" });
catalogDb.products.createIndex(
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
catalogDb.provider_portfolios.createIndex({ "providerId": 1 }, { unique: true, name: "uq_portfolios_provider_id" });
catalogDb.provider_portfolios.createIndex({ "serviceLocationGeo": "2dsphere" }, { name: "geo_portfolios_location", sparse: true });

print("Creating indexes on collection: reviews...");
catalogDb.reviews.createIndex({ "bookingId": 1 }, { unique: true, name: "uq_reviews_booking_id" });
catalogDb.reviews.createIndex({ "providerId": 1, "createdAt": -1 }, { name: "ix_reviews_provider_created" });
catalogDb.reviews.createIndex({ "customerId": 1, "createdAt": -1 }, { name: "ix_reviews_customer_created" });

print("All MongoDB indexes established successfully.");
