# == Schema Information
#
# Table name: products
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  available_stock :integer          not null
#  description     :text(65535)
#  name            :string(255)      not null
#  price           :decimal(10, 2)   not null
#  reserved_stock  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_products_on_name  (name) UNIQUE
#
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
