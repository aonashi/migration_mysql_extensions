module MigrationMysqlExtensions
  module ActiveRecord
    module ConnectionAdapters
      module Mysql2Adapter
        def self.included(base)
          base.class_eval do
            alias_method_chain :new_column, :mysql_extensions
          end
        end

        def new_column_with_mysql_extensions(field, default, type, null, collation, extra = "", comment, primary_key)
          column = new_column_without_mysql_extensions(field, default, type, null, collation, extra)
          column.comment = comment
          if type.present?
            column.unsigned = type.include? 'unsigned'
          else
            column.unsigned = false
          end
          column.primary = primary_key
          return column
        end
      end
    end
  end
end
