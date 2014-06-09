module MigrationMysqlExtensions
  module ActiveRecord
    module ConnectionAdapters
      module TableDefinition
        def self.included(base)
          base.class_eval do
            alias_method_chain :new_column_definition, :mysql_extensions
            alias_method_chain :references, :mysql_extensions
          end
        end

        def new_column_definition_with_mysql_extensions(name, type, options)
          column = new_column_definition_without_mysql_extensions(name, type, options)
          column.unsigned    = options[:unsigned]
          column.comment     = options[:comment]
          column
        end

        def references_with_mysql_extensions(*args)
          options = args.extract_options!
          polymorphic = options.delete(:polymorphic)
          index_options = options.delete(:index)
          args.each do |col|
            column("#{col}_id", :integer, options.merge(unsigned: true))
            column("#{col}_type", :string, polymorphic.is_a?(Hash) ? polymorphic : options) if polymorphic
            index(polymorphic ? %w(id type).map { |t| "#{col}_#{t}" } : "#{col}_id", index_options.is_a?(Hash) ? index_options : {}) if index_options
          end
        end
      end
    end
  end
end
