# Migration MySQL Extensions

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'migration_mysql_extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install migration_mysql_extensions

## Usage

### primary key

PRIMARY KEY is set to `unsigned int` by default.

### non-integer primary key

varchar(5) primary key

    create_table :books, id: false do |t|
      t.string :code, limit: 5, primary_key: true
    end

### unsigned column

    create_table :users do |t|
      t.integer :age, unsigned: true
    end

### add comment

column comment

    create_table :users do |t|
      t.string :nickname, comment: "user's nickname"
    end

table comment

    create_table :admin_users, comment: "administrator"


## Contributing

1. Fork it ( https://github.com/aonashi/migration_mysql_extensions/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
