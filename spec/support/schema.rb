def column_type(table_name, column_name)
  ActiveRecord::Base.connection.retrieve_column_type(table_name.to_s, column_name.to_s)
end

def table_comment(table_name)
  ActiveRecord::Base.connection.retrieve_table_comment(table_name.to_s)
end

def column_comment(table_name, column_name)
  ActiveRecord::Base.connection.retrieve_column_comment(table_name.to_s, column_name.to_s)
end

def schema_dump
  dest = StringIO.new
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
  dest.rewind
  dest.read
end

def is_primary_key_column?(table_name, column_name)
  connection = ActiveRecord::Base.connection

  if connection.respond_to?(:pk_and_sequence_for)
    pk, _ = connection.pk_and_sequence_for(table_name.to_s)
  elsif connection.respond_to?(:primary_key)
    pk = connection.primary_key(table_name.to_s)
  end

  pk && pk == column_name.to_s
end
