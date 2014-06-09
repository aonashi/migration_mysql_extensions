require 'migration_mysql_extensions/version'
require 'active_support/all'

module MigrationMysqlExtensions
  module ActiveRecord
    extend ActiveSupport::Autoload

    autoload :SchemaDumper

    module ConnectionAdapters
      extend ActiveSupport::Autoload

      autoload :ColumnDefinition
      autoload :TableDefinition
      autoload :ColumnDumper
      autoload :AbstractMysqlAdapter
      autoload :Mysql2Adapter

      module AbstractMysqlAdapter
        extend ActiveSupport::Autoload

        autoload :Column
        autoload :SchemaCreation
      end
    end

    module Migration
      extend ActiveSupport::Autoload

      autoload :CommandRecorder
    end
  end
end

if defined?(Rails)
  require 'migration_mysql_extensions/hooks'
  require 'migration_mysql_extensions/railtie'
end
