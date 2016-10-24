# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$:.push File.expand_path("../lib", __FILE__)
require "kaminari/version"

Gem::Specification.new do |s|
  s.name        = 'kaminari'
  s.version     = Kaminari::VERSION
  s.authors     = ['Akira Matsuda', 'Yuki Nishijima', 'Zachary Scott', 'Hiroshi Shibata']
  s.email       = ['ronnie@dio.jp']
  s.homepage    = 'https://github.com/amatsuda/kaminari'
  s.summary     = 'A pagination engine plugin for Rails 4+ and other modern frameworks'
  s.description = 'Kaminari is a Scope & Engine based, clean, powerful, agnostic, customizable and sophisticated paginator for Rails 4+'
  s.license       = "MIT"

  s.files         = `git ls-files | egrep -v 'kaminari-(core|actionview|activerecord)' | grep -v '^spec'`.split("\n")
  s.test_files    = `git ls-files spec`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 4.1.0'
  s.add_dependency 'kaminari-core'
  s.add_dependency 'kaminari-actionview'
  s.add_dependency 'kaminari-activerecord'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake', '>= 0'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'rr', '>= 0'
  s.add_development_dependency 'capybara', '>= 1.0'
  s.add_development_dependency 'database_cleaner', '>= 1.4.1'
end
