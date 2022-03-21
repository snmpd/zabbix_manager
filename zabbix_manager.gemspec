# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "zabbix_manager/version"

Gem::Specification.new do |spec|
  spec.add_dependency "http", "~> 4.0"
  spec.add_dependency "json", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 2.3", ">= 2.3.9"

  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "yard", "~> 0.9.27"
  spec.add_development_dependency "yardstick", "~> 0.9.9"
  spec.add_development_dependency "rubocop", "~> 1.25", ">= 1.25.1"
  spec.add_development_dependency "rubocop-minitest", "~> 0.18.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.13"
  spec.add_development_dependency "rubocop-rails", "~> 2.13", ">= 2.13.2"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.1"

  spec.name    = "zabbix_manager"
  spec.version = ZabbixManager::VERSION
  spec.authors = ["WENWU YAN"]
  spec.email   = ["careline@foxmail.com"]

  spec.summary     = "Simple and lightweight ruby module for working with the Zabbix API, support 4.0 5.0 6.0"
  spec.description = "Most codes borrowed from ZabbixApi, But changed some logic for everyday jobs."
  spec.homepage    = "https://github.com/snmpd/zabbix_manager"
  spec.licenses    = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/snmpd/zabbix_manager"
  spec.metadata["changelog_uri"]   = "https://github.com/snmpd/zabbix_manager"

  spec.files                 = %w[CHANGELOG.md LICENSE.txt README.md zabbix_manager.gemspec] + Dir["lib/**/*.rb"]
  spec.require_paths         = "lib"
  spec.required_ruby_version = ">= 2.7.0"
end
