# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  minimum_coverage 100
  add_filter "lib/nokodiff/engine.rb"
end

require "nokodiff"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string"
require "rspec-html-matchers"
require "rails"
# require "rspec/rails"
# require "capybara/rails"
# require File.expand_path("../dummy/config/environment", __FILE__)
require "nokodiff/engine"

Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpecHtmlMatchers
  # config.include Capybara::DSL, capybara: true # , visual_regression: true

  config.filter_run_excluding not_applicable: true # , visual_regression: true
  # Need to treat Dummy as app. See:
  # https://stackoverflow.com/questions/19867202/combining-url-helpers-for-a-rails-engine-and-a-base-application-in-rspec

  config.before do |example|
    # Visual regression tests need the JS driver to be used for screenshots
    Capybara.current_driver = Capybara.javascript_driver # if example.metadata[:visual_regression]
  end

  # config.include Rails.application.routes.url_helpers
  # config.include Engine.routes.url_helpers
end
