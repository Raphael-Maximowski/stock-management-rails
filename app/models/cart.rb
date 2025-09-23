# == Schema Information
#
# Table name: carts
#
#  id           :bigint           not null, primary key
#  cart_status  :string(255)      default("active")
#  expires_at   :datetime         not null
#  total_amount :decimal(10, 2)   default(0.0)
#  total_items  :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_carts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Cart < ApplicationRecord
    belongs_to :user

    has_many :cart_products
    has_many :stock_reservations
    has_many :stock_histories
end
