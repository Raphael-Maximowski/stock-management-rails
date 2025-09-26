db_config = {
  adapter: 'mysql2',
  encoding: 'utf8mb4',
  pool: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
  timeout: 5000,
  username: ENV.fetch('DB_USERNAME', 'root'),
  password: ENV.fetch('DB_PASSWORD', 'password'),
  host: ENV.fetch('DB_HOST', 'localhost'),
  port: ENV.fetch('DB_PORT', 3306).to_i
}

ActiveRecord::Base.configurations = {
  'development' => db_config.merge(database: 'stock_management_development'),
  'test' => db_config.merge(database: 'stock_management_test'),
  'production' => db_config.merge(database: 'stock_management_production')
}