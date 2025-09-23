class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.string :cart_status, default: 'active'
      t.integer :total_items, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.datetime :expires_at, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
