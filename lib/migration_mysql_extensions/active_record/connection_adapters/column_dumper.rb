module MigrationMysqlExtensions
  module ActiveRecord
    module ConnectionAdapters
      module ColumnDumper
        def self.included(base)
          base.class_eval do
            alias_method_chain :prepare_column_options, :mysql_extensions
            alias_method_chain :migration_keys, :mysql_extensions
          end
        end

        def prepare_column_options_with_mysql_extensions(column, types)
          spec = prepare_column_options_without_mysql_extensions(column, types)
          if column.primary
            spec.delete(:null)
            spec[:primary_key] = default_string(column.primary)
          end
          spec[:unsigned] = 'true' if column.unsigned
          spec[:comment] = default_string(column.comment) if column.comment.present?
          spec
        end

        def migration_keys_with_mysql_extensions
          migration_keys_without_mysql_extensions + [:unsigned, :comment, :primary_key]
        end
      end
    end
  end
end
