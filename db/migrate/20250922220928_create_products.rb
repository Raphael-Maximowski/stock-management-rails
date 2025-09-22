class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :available_stock, null: false
      t.integer :reserved_stock, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :products, :name, unique: true
    add_check_constraint :products, "price >= 0", name: "positive_price"
    add_check_constraint :products, "available_stock >= 0", name: "positive_avaliable_stock"
    add_check_constraint :products, "reserved_stock >= 0", name: "positive_reserved_stock"
  end
end
