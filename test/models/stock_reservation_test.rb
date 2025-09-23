# == Schema Information
#
# Table name: stock_reservations
#
#  id                 :bigint           not null, primary key
#  quantity           :integer          not null
#  reservation_status :string(255)      default("active")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cart_id            :bigint           not null
#  product_id         :bigint           not null
#
# Indexes
#
#  index_stock_reservations_on_cart_id     (cart_id)
#  index_stock_reservations_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (product_id => products.id)
#
require "test_helper"

class StockReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
