module MigrationMysqlExtensions
  class Railtie < Rails::Railtie
    initializer 'migration_mysql_extensions' do
      ActiveSupport.on_load :active_record do
        if ::ActiveRecord::VERSION::MAJOR == 4
          MigrationMysqlExtensions.init
        end
      end
    end
  end
end
