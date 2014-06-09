require 'spec_helper'

describe :table_comment do
  after do
    ActiveRecord::Schema.define do
      drop_table :users rescue nil
    end
  end

  subject { table_comment(:users) }

  context 'create a table with table comment' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, comment: 'users table', force: true
      end
    end

    specify { is_expected.to eq 'users table' }
  end

  context 'create a table without table comment' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true
      end
    end

    specify { is_expected.to be_nil }
  end

  describe 'dump to schema.rb' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true, comment: 'users table' do |t|
        end
      end
    end

    subject { schema_dump }

    let(:expected) {
      expected = <<-EOC
  create_table "users", force: true, comment: "users table" do |t|
  end
      EOC
    }

    specify { is_expected.to match /#{Regexp.escape(expected)}/ }
  end
end
