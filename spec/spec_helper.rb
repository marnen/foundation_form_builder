require 'rubygems'
require 'bundler/setup'
require 'ffaker'
require 'rspec-html-matchers'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'foundation_form_builder'

RSpec.configure do |config|
  config.include RSpecHtmlMatchers
end