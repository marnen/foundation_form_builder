# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foundation_form_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "foundation_form_builder"
  spec.version       = FoundationFormBuilder::VERSION
  spec.authors       = ["Marnen Laibow-Koser"]
  spec.email         = ["marnen@marnen.org"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'actionview', '>= 4.2.0'
  spec.add_dependency 'activerecord', '>= 4.2.0'
  spec.add_dependency 'activesupport', '>= 4.2.0'

  [
    ['bundler', '~> 1.8'],
    ['rake', '~> 10.0'],
    'ffaker',
    'guard-rspec',
    'rspec-html-matchers'
  ].each {|gem| spec.add_development_dependency *gem }
end
