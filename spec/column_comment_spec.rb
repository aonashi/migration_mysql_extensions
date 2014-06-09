require 'spec_helper'

describe :column_comment do
  after do
    ActiveRecord::Schema.define do
      drop_table :users rescue nil
    end
  end

  subject { column_comment(:users, :name) }

  context 'create a table with column comment' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :name, comment: "user's full name"
        end
      end
    end

    specify { is_expected.to eq "user's full name" }
  end

  context 'create a table without column comment' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :name
        end
      end
    end

    specify { is_expected.to be_nil }
  end

  describe 'dump to schema.rb' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :name, comment: "user's full name"
        end
      end
    end

    subject { schema_dump }

    let(:expected) {
      expected = <<-EOC
  create_table "users", force: true do |t|
    t.string "name", comment: "user's full name"
  end
      EOC
    }

    specify { is_expected.to match /#{Regexp.escape(expected)}/ }
  end
end
