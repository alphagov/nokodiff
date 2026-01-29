# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nokodiff/version"

Gem::Specification.new do |spec|
  spec.name          = "nokodiff"
  spec.version       = Nokodiff::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "A Ruby Gem to highlight additions, deletions and character level changes while preserving original HTML"
  spec.homepage      = "https://github.com/alphagov/nokodiff"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.2"
  spec.files = Dir[
    "{node_modules/govuk-frontend,app,lib}/**/*", "LICENCE.txt", "README.md"
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "rake", "13.3.1"
  spec.add_development_dependency "rspec-html-matchers", "0.10.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop-govuk", "5.2.0"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "actionview", ">= 6", "< 8.1.3"
  spec.add_dependency "diff-lcs"
  spec.add_dependency "gds-api-adapters", ">= 101.0", "< 102.1"
  spec.add_dependency "govspeak", ">= 10.6.3"
  spec.add_dependency "rails", ">= 6", "< 8.1.3"
  spec.add_dependency "view_component", "~> 4"
end
