module MigrationMysqlExtensions
  module ActiveRecord
    module ConnectionAdapters
      module AbstractMysqlAdapter
        def self.included(base)
          base.class_eval do
            alias_method_chain :native_database_types, :mysql_extensions
            alias_method_chain :create_table, :mysql_extensions
            alias_method_chain :new_column, :mysql_extensions
            alias_method_chain :columns, :mysql_extensions
            alias_method_chain :type_to_sql, :mysql_extensions

            base::Column.class_eval do
              attr_accessor :unsigned, :comment
            end
            base::SchemaCreation.send :include, SchemaCreation
          end
        end

        module SchemaCreation
          def self.included(base)
            base.class_eval do
              alias_method_chain :visit_AddColumn, :mysql_extensions
              alias_method_chain :visit_ChangeColumnDefinition, :mysql_extensions
              alias_method_chain :visit_ColumnDefinition, :mysql_extensions
              alias_method_chain :column_options, :mysql_extensions
              alias_method_chain :add_column_options!, :mysql_extensions
              alias_method_chain :type_to_sql, :mysql_extensions
            end
          end

          def visit_AddColumn_with_mysql_extensions(o)
            sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
            sql = "ADD #{quote_column_name(o.name)} #{sql_type}"
            add_column_options!(sql, column_options(o))
          end

          def visit_ChangeColumnDefinition_with_mysql_extensions(o)
            column = o.column
            options = o.options
            sql_type = type_to_sql(o.type, options[:limit], options[:precision], options[:scale], options[:unsigned])
            change_column_sql = "CHANGE #{quote_column_name(column.name)} #{quote_column_name(options[:name])} #{sql_type}"
            add_column_options!(change_column_sql, options)
            add_column_position!(change_column_sql, options)
          end

          def visit_ColumnDefinition_with_mysql_extensions(o)
            sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
            column_sql = "#{quote_column_name(o.name)} #{sql_type}"
            add_column_options!(column_sql, column_options(o))
            column_sql
          end

          def column_options_with_mysql_extensions(o)
            column_options = column_options_without_mysql_extensions(o)
            column_options[:primary_key] = o.primary_key
            column_options[:comment] = o.comment
            column_options
          end

          def add_column_options_with_mysql_extensions!(sql, options)
            sql = add_column_options_without_mysql_extensions!(sql, options)
            if options[:primary_key] == true
              sql << " AUTO_INCREMENT" if options[:column].type == :integer
              sql << " PRIMARY KEY"
            end
            sql << " COMMENT '#{options[:comment].gsub("'", "''")}'" if options[:comment].present?
            sql
          end

          def type_to_sql_with_mysql_extensions(type, limit, precision, scale, unsigned)
            @conn.type_to_sql type.to_sym, limit, precision, scale, unsigned
          end
        end

        def native_database_types_with_mysql_extensions
          native_database_types_without_mysql_extensions.merge(
            primary_key: 'int(10) unsigned DEFAULT NULL auto_increment PRIMARY KEY'
          )
        end

        def create_table_with_mysql_extensions(table_name, options = {}, &block)
          options_string = []
          if options.has_key?(:options)
            options_string << options[:options]
          else
            options_string << 'ENGINE=InnoDB'
          end
          options_string << " COMMENT='#{options[:comment]}'" if options.has_key?(:comment)

          options[:options] = options_string.join(' ')
          create_table_without_mysql_extensions(table_name, options, &block)
        end

        def type_to_sql_with_mysql_extensions(type, limit = nil, precision = nil, scale = nil, unsigned = nil)
          unless type.to_s == 'integer'
            type_to_sql_without_mysql_extensions(type, limit, precision, scale)
          else
            case limit
            when 1; 'tinyint' + (unsigned ? ' unsigned' : '')
            when 2; 'smallint' + (unsigned ? ' unsigned' : '')
            when 3; 'mediumint' + (unsigned ? ' unsigned' : '')
            when nil, 4, 11
              # compatibility with MySQL default
              unsigned ? 'int(10) unsigned' : 'int(11)'
            when 5..8; 'bigint' + (unsigned ? ' unsigned' : '')
            else raise(ActiveRecordError, "No integer type has byte size #{limit}")
            end
          end
        end

        def new_column_with_mysql_extensions(field, default, type, null, collation, extra = "", comment, primary_key)
          Column.new(field, default, type, null, collation, extra, comment, primary_key)
        end

        def columns_with_mysql_extensions(table_name)
          sql = "SHOW FULL FIELDS FROM #{quote_table_name(table_name)}"
          execute_and_free(sql, 'SCHEMA') do |result|
            each_hash(result).map do |field|
              field_name = set_field_encoding(field[:Field])
              new_column(field_name, field[:Default], field[:Type], field[:Null] == "YES", field[:Collation], field[:Extra], field[:Comment], field[:Key] == "PRI")
            end
          end
        end

        def retrieve_table_comment(table_name)
          result = select_rows(table_comment_sql(table_name))
          result[0].nil? || result[0][0].blank? ? nil : result[0][0]
        end

        def retrieve_column_comment(table_name, column_name)
          result = select_rows <<-SQL
            SELECT COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = '#{database_name}'
              AND TABLE_NAME = '#{table_name}'
              AND COLUMN_NAME = '#{column_name}'
          SQL
          result[0].nil? || result[0][0].presence
        end

        def retrieve_column_type(table_name, column_name)
          result = select_rows <<-SQL
            SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = '#{database_name}'
              AND TABLE_NAME = '#{table_name}'
              AND COLUMN_NAME = '#{column_name}'
          SQL
          result[0].nil? || result[0][0].presence
        end

        def table_comment_sql(table_name)
          <<-SQL
            SELECT table_comment FROM INFORMATION_SCHEMA.TABLES
            WHERE table_schema = '#{database_name}'
            AND table_name = '#{table_name}'
          SQL
        end

        def database_name
          @database_name ||= select_rows('SELECT DATABASE()')[0][0]
        end
      end
    end
  end
end
