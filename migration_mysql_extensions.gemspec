# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'migration_mysql_extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "migration_mysql_extensions"
  spec.version       = MigrationMysqlExtensions::VERSION
  spec.authors       = ["aonashi"]
  spec.email         = ["aonashi010@gmail.com"]
  spec.summary       = %q{extended migration methods for MySQL.}
  spec.description   = %q{extended migration methods for MySQL.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 4.0.0'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "activesupport"
end
