# == Schema Information
#
# Table name: stock_histories
#
#  id                     :bigint           not null, primary key
#  available_stock_after  :integer          not null
#  available_stock_before :integer          not null
#  event_type             :string(255)      not null
#  reason                 :text(65535)
#  reserved_stock_after   :integer          not null
#  reserved_stock_before  :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  cart_id                :bigint           not null
#  product_id             :bigint           not null
#
# Indexes
#
#  index_stock_histories_on_cart_id     (cart_id)
#  index_stock_histories_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (product_id => products.id)
#
require "test_helper"

class StockHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
