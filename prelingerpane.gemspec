# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prelingerpane/version'

Gem::Specification.new do |gem|
  gem.name        = "prelingerpane"
  gem.version     = Prelingerpane::VERSION
  gem.authors     = ["TODO: Write your name"]
  gem.email       = ["TODO: Write your email address"]
  gem.description = %q{TODO: Write a gem description}
  gem.summary     = %q{TODO: Write a gem summary}
  gem.homepage    = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "faraday"
  gem.add_dependency "faraday_middleware"
  gem.add_dependency 'highline'
  gem.add_dependency 'nokogiri', "~> 1.8.2"
  gem.add_dependency "sinatra"
  gem.add_dependency "thin"

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'guard', '~> 1.4.0' if RUBY_PLATFORM =~ /(darwin|win32|w32)/i
  gem.add_development_dependency 'guard-rspec' if RUBY_PLATFORM =~ /(darwin|win32|w32)/i
  gem.add_development_dependency 'terminal-notifier-guard', '~> 1.5.3' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'turn', '< 0.8.3' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.1' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sinatra-reloader'
end
