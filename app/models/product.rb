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
#  reserved_stock  :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_products_on_name     (name) UNIQUE
#  index_products_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Product < ApplicationRecord
    has_many :cart_products
    has_many :stock_histories
    has_many :stock_reservations
end
