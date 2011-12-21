# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kaminari/version"

Gem::Specification.new do |s|
  s.name        = 'kaminari'
  s.version     = Kaminari::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Akira Matsuda']
  s.email       = ['ronnie@dio.jp']
  s.homepage    = 'https://github.com/amatsuda/kaminari'
  s.summary     = 'A pagination engine plugin for Rails 3 or other modern frameworks'
  s.description = 'Kaminari is a Scope & Engine based, clean, powerful, agnostic, customizable and sophisticated paginator for Rails 3'

  s.rubyforge_project = 'kaminari'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  %w{ activesupport actionpack railties }.each do |gem|
    s.add_dependency gem, ['>= 3.0.0']
  end
  s.add_development_dependency 'bundler', ['>= 1.0.0']
  s.add_development_dependency 'sqlite3', ['>= 0']
  %w{ activerecord activemodel }.each do |gem|
    s.add_development_dependency gem, ['>= 3.0.0']
  end
  s.add_development_dependency 'sinatra', ['>= 1.3']
  s.add_development_dependency 'mongoid', ['>= 2']
  s.add_development_dependency 'mongo_mapper', ['>= 0.9']
  s.add_development_dependency 'dm-core', ['>= 1.1.0']
  s.add_development_dependency 'dm-migrations', ['>= 1.1.0']
  s.add_development_dependency 'dm-aggregates', ['>= 1.1.0']
  s.add_development_dependency 'dm-sqlite-adapter', ['>= 1.1.0']
  s.add_development_dependency 'rspec', ['>= 0']
  s.add_development_dependency 'rspec-rails', ['>= 0']
  s.add_development_dependency 'rr', ['>= 0']
  s.add_development_dependency 'capybara', ['>= 1.0']
  s.add_development_dependency 'database_cleaner', ['>= 0']
  s.add_development_dependency 'padrino-helpers', ['~> 0.10']
  s.add_development_dependency 'rack-test', ['>= 0']
  s.add_development_dependency 'sinatra-contrib', ['~> 1.3']
  s.add_development_dependency 'nokogiri', ['>= 0']
end
