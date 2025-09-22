class CreateStockReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_reservations do |t|
      t.integer :quantity, null: false
      t.string :reservation_status, default: 'active'
      t.datetime :expires_at, null: false

      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
