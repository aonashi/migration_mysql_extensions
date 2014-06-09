module MigrationMysqlExtensions
  module ActiveRecord
    module ConnectionAdapters
      module ColumnDefinition
        def self.included(base)
          base.class_eval do
            attr_accessor :unsigned, :comment
          end
        end
      end
    end
  end
end
