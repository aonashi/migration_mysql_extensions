module MigrationMysqlExtensions
  def self.init
    ::ActiveRecord::Migration::CommandRecorder.send :include,
      MigrationMysqlExtensions::ActiveRecord::Migration::CommandRecorder

    base_names = %w(SchemaDumper) +
      %w(ColumnDumper ColumnDefinition TableDefinition AbstractMysqlAdapter Mysql2Adapter).map{|name| "ConnectionAdapters::#{name}"}

    base_names.each do |base_name|
      base_class = "ActiveRecord::#{base_name}".constantize
      mysql_extensions_class = "MigrationMysqlExtensions::ActiveRecord::#{base_name}".constantize
      base_class.send :include, mysql_extensions_class
    end
  end
end
