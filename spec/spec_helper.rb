# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  minimum_coverage 100
  skip "lib/nokodiff/engine.rb"
end

require "nokodiff"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string"
require "rspec-html-matchers"

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

  config.filter_run_excluding not_applicable: true # , visual_regression: true
  # Need to treat Dummy as app. See:
  # https://stackoverflow.com/questions/19867202/combining-url-helpers-for-a-rails-engine-and-a-base-application-in-rspec

  config.before do |example|
    # Visual regression tests need the JS driver to be used for screenshots
    Capybara.current_driver = Capybara.javascript_driver if example.metadata[:visual_regression]
  end
end
