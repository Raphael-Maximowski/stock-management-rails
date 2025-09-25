user_schemas_path = Rails.root.join('app', 'validators', 'schemas', 'user')
require File.join(user_schemas_path, 'user_base_schema')
require File.join(user_schemas_path, 'user_create_schema')
require File.join(user_schemas_path, 'user_update_schema')
require File.join(user_schemas_path, 'user_login_schema')

product_schemas_path = Rails.root.join('app', 'validators', 'schemas', 'product')
require File.join(product_schemas_path, 'product_create_schema')
require File.join(product_schemas_path, 'product_update_schema')

cart_schemas_path = Rails.root.join('app', 'validators', 'schemas', 'cart')
require File.join(cart_schemas_path, 'cart_manipulation_schema')
require File.join(cart_schemas_path, 'manipulate_cart_product_schema')