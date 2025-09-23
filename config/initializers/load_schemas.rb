user_schemas_path = Rails.root.join('app', 'validators', 'schemas', 'user')
require File.join(user_schemas_path, 'user_base_schema')
require File.join(user_schemas_path, 'user_create_schema')
require File.join(user_schemas_path, 'user_update_schema')
