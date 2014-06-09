require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  database: 'migration_mysql_extensions_test',
  username: 'root',
  password: ''
)

module MigrationMysqlExtensionsTestApp
  class Application < Rails::Application
    config.active_support.deprecation = :log
    config.eager_load = false
  end
end
MigrationMysqlExtensionsTestApp::Application.initialize!
