class CreateStockHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_histories do |t|
      t.string :event_type, null: false
      t.integer :reserved_stock_before, null: false
      t.integer :reserved_stock_after, null: false
      t.integer :available_stock_before, null: false
      t.integer :available_stock_after, null: false
      t.text :reason

      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
