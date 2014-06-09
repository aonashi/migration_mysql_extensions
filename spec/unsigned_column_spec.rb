require 'spec_helper'

describe :unsigned_column do
  after do
    ActiveRecord::Schema.define do
      drop_table :users rescue nil
    end
  end

  describe :primary_key do
    context 'default primary_key' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true
        end
      end
      specify { expect(column_type(:users, :id)).to eq 'int(10) unsigned' }
    end

    context 'name is not id' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, primary_key: :code, force: true
        end
      end
      specify { expect(column_type(:users, :code)).to eq 'int(10) unsigned' }
    end

    context 'with :primary_key type' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, id: false, force: true do |t|
            t.primary_key :code
          end
        end
      end
      specify { expect(column_type(:users, :code)).to eq 'int(10) unsigned' }
    end
  end

  context 'foreign_key' do
    before do
      ActiveRecord::Schema.define do
        create_table :roles, force: true
        create_table :users, force: true do |t|
          t.references :role, index: true
        end
      end
    end
    after do
      ActiveRecord::Schema.define do
        drop_table :roles rescue nil
      end
    end
    specify { expect(column_type(:users, :role_id)).to eq 'int(10) unsigned' }
  end

#  context 'add_reference' do
#    before do
#      ActiveRecord::Schema.define do
#        create_table :people, force: true
#        add_reference :people, :person, index: true
#      end
#    end
#
#    it { expect(column_type('people', 'person_id')).to eq 'int(10) unsigned' }
#  end

  describe 'default integer column' do
    subject { column_type(:users, :age) }

    context 'create a table' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true do |t|
            t.integer :age
          end
        end
      end
      specify { is_expected.to eq 'int(11)' }
    end

    context 'add_column' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true
          add_column :users, :age, :integer
        end
      end
      specify { is_expected.to eq 'int(11)' }
    end
  end

  describe 'unsigned integer column' do
    subject { column_type(:users, :age) }

    context 'create a table' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true do |t|
            t.integer :age, unsigned: true
          end
        end
      end
      specify { is_expected.to eq 'int(10) unsigned' }
    end

    context 'add column' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true
          add_column :users, :age, :integer, unsigned: true
        end
      end
      specify { is_expected.to eq 'int(10) unsigned' }
    end
  end

  describe 'specify non-unsigned integer column' do
    subject { column_type(:users, :age) }

    context 'create a table' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true do |t|
            t.integer :age, unsigned: false
          end
        end
      end
      specify { is_expected.to eq 'int(11)' }
    end

    context 'add column' do
      before do
        ActiveRecord::Schema.define do
          create_table :users, force: true
          add_column :users, :age, :integer, unsigned: false
        end
      end
      specify { is_expected.to eq 'int(11)' }
    end
  end

  context 'change to unsigned column' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.integer :age
        end
      end
    end

    specify do
      expect do
        ActiveRecord::Schema.define do
          change_column :users, :age, :integer, unsigned: true
        end
      end.to change { column_type(:users, :age) }.from('int(11)').to('int(10) unsigned')
    end
  end

  describe 'dump to schema.rb' do
    before do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.integer :age, unsigned: true
          t.integer :point
        end
      end
    end

    subject { schema_dump }

    let(:expected) {
      expected = <<-EOC
  create_table "users", force: true do |t|
    t.integer "age", __SPACES__unsigned: true
    t.integer "point"
  end
      EOC
    }

    it { should match /#{Regexp.escape(expected).gsub(/__SPACES__/, "\s+")}/ }
  end

end
