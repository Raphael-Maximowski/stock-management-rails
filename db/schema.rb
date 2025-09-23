# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_22_230920) do
  create_table "cart_products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quantity", null: false
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_products_on_cart_id"
    t.index ["product_id"], name: "index_cart_products_on_product_id"
  end

  create_table "carts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cart_status", default: "active"
    t.integer "total_items", default: 0
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "available_stock", null: false
    t.integer "reserved_stock", default: 0
    t.boolean "active", default: true
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
    t.check_constraint "`available_stock` >= 0", name: "positive_avaliable_stock"
    t.check_constraint "`price` >= 0", name: "positive_price"
    t.check_constraint "`reserved_stock` >= 0", name: "positive_reserved_stock"
  end

  create_table "stock_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event_type", null: false
    t.integer "reserved_stock_before", null: false
    t.integer "reserved_stock_after", null: false
    t.integer "available_stock_before", null: false
    t.integer "available_stock_after", null: false
    t.text "reason"
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_stock_histories_on_cart_id"
    t.index ["product_id"], name: "index_stock_histories_on_product_id"
  end

  create_table "stock_reservations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quantity", null: false
    t.string "reservation_status", default: "active"
    t.datetime "expires_at", null: false
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_stock_reservations_on_cart_id"
    t.index ["product_id"], name: "index_stock_reservations_on_product_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "manager"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "cart_products", "carts"
  add_foreign_key "cart_products", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "products", "users"
  add_foreign_key "stock_histories", "carts"
  add_foreign_key "stock_histories", "products"
  add_foreign_key "stock_reservations", "carts"
  add_foreign_key "stock_reservations", "products"
end
