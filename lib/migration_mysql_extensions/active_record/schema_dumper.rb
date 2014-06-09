#require 'active_record/schema_dumper'

module MigrationMysqlExtensions
  module ActiveRecord
    module SchemaDumper
      def self.included(base)
        base.class_eval do
          alias_method_chain :table, :mysql_extensions
        end
      end

      def table_with_mysql_extensions(table, stream)
        columns = @connection.columns(table)

        table_name = table.inspect.gsub('"', '')
        table_comment = @connection.retrieve_table_comment(table_name)

        begin
          tbl = StringIO.new

          # first dump primary key column
          if @connection.respond_to?(:pk_and_sequence_for)
            pk, _ = @connection.pk_and_sequence_for(table)
          elsif @connection.respond_to?(:primary_key)
            pk = @connection.primary_key(table)
          end

          tbl.print "  create_table #{remove_prefix_and_suffix(table).inspect}"
          pkcol = columns.detect { |c| c.name == pk }
          # TODO
          if pkcol
            if pkcol.sql_type == 'uuid'
              tbl.print ", id: :uuid"
              tbl.print %Q(, default: "#{pkcol.default_function}") if pkcol.default_function
            elsif pkcol.sql_type != 'int(10) unsigned'
              tbl.print ", id: false"
            else
              tbl.print %Q(, primary_key: "#{pk}") if pk != 'id'
            end
          end
          tbl.print ", force: true"

          # table comment
          if table_comment.present?
            tbl.print ", #{render_kv_pair(:comment, table_comment)}"
          end

          tbl.puts " do |t|"

          # then dump all non-default-primary key columns
          column_specs = columns.map do |column|
            raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" unless @connection.valid_type?(column.type)

            next if pk == column.name && column.name == 'id' && column.sql_type == 'int(10) unsigned'

            @connection.column_spec(column, @types)
          end.compact

          # find all migration keys used in this table
          keys = @connection.migration_keys

          # figure out the lengths for each column based on above keys
          lengths = keys.map { |key|
            column_specs.map { |spec|
              spec[key] ? spec[key].length + 2 : 0
            }.max
          }

          # the string we're going to sprintf our values against, with standardized column widths
          format_string = lengths.map{ |len| "%-#{len}s" }

          # find the max length for the 'type' column, which is special
          type_length = column_specs.map{ |column| column[:type].length }.max

          # add column type definition to our format string
          format_string.unshift "    t.%-#{type_length}s "

          format_string *= ''

          column_specs.each do |colspec|
            values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
            values.unshift colspec[:type]
            tbl.print((format_string % values).gsub(/,\s*$/, ''))
            tbl.puts
          end

          tbl.puts "  end"
          tbl.puts

          indexes(table, tbl)

          tbl.rewind
          stream.print tbl.read
        rescue => e
          stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
          stream.puts "#   #{e.message}"
          stream.puts
        end

        stream
      end

      def render_kv_pair(key, value)
        "#{key}: #{render_value(value)}"
      end

      def render_value(value)
        value.is_a?(String) ? %Q[#{value}].inspect : value
      end
    end
  end
end
