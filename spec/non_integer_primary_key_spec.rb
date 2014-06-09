require 'spec_helper'

describe :non_integer_primary_key do
  after do
    ActiveRecord::Schema.define do
      drop_table :users rescue nil
    end
  end

  context 'type is string (varchar)' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, id: false, force: true do |t|
          t.string :code, limit: 5, primary_key: true
        end
      end
    end
    specify { expect(is_primary_key_column?(:users, :code)).to be_truthy }
    specify { expect(column_type(:users, :code)).to eq 'varchar(5)' }

    let(:expected_schema) {
      expected = <<-EOC
  create_table "users", id: false, force: true do |t|
    t.string "code", limit: 5, primary_key: true
  end
      EOC
    }
    specify { expect(schema_dump).to match /#{Regexp.escape(expected_schema)}/ }
  end

  context 'type is integer (mediumint)' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, id: false, force: true do |t|
          t.integer :id, unsigned: true, primary_key: true
        end
      end
    end
    specify { expect(is_primary_key_column?(:users, :id)).to be_truthy }
    specify { expect(column_type(:users, :id)).to eq 'int(10) unsigned' }

    let(:expected_schema) {
      expected = <<-EOC
  create_table "users", force: true do |t|
  end
      EOC
    }
    specify { expect(schema_dump).to match /#{Regexp.escape(expected_schema)}/ }
  end

  context 'type is integer (mediumint)' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, id: false, force: true do |t|
          t.integer :id, limit: 3, unsigned: true, primary_key: true
        end
      end
    end
    specify { expect(is_primary_key_column?(:users, :id)).to be_truthy }
    specify { expect(column_type(:users, :id)).to eq 'mediumint(8) unsigned' }

    let(:expected_schema) {
      expected = <<-EOC
  create_table "users", id: false, force: true do |t|
    t.integer "id", limit: 3, unsigned: true, primary_key: true
  end
      EOC
    }
    specify { expect(schema_dump).to match /#{Regexp.escape(expected_schema)}/ }
  end
end
