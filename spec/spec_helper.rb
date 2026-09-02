# frozen_string_literal: true

# require "rails_helper"
# require "percy/capybara"
require "simplecov"
SimpleCov.start do
  minimum_coverage 100
  add_filter "lib/nokodiff/engine.rb"
end

require "nokodiff"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string"
require "rspec-html-matchers"
# require "url_helpers"

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

  config.filter_run_excluding not_applicable: true, visual_regression: true
  # Need to treat Dummy as app. See: 
  # https://stackoverflow.com/questions/19867202/combining-url-helpers-for-a-rails-engine-and-a-base-application-in-rspec
  # config.include RSpec.application.routes.url_helpers, type: :feature
  # config.include Rails.application.routes.url_helpers, type: :feature
end
