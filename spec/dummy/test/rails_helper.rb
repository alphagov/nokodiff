require "spec_helper"
# ENV["RAILS_ENV"] ||= "test"
# require File.expand_path("dummy/config/environment", __dir__)
# abort("The Rails environment is running in production mode!") if Rails.env.production?
# require "rspec/rails"
# require "capybara/rails"
# require "govuk_test"
# require "climate_control"
require "nokodiff/engine"

# GovukTest.configure
# Selenium::WebDriver::Options.chrome(loggingPrefs: { browser: "ALL" })

RSpec.configure do |config|
  # config.include Engine.routes.url_helpers
  # config.include Capybara::DSL, capybara: true, visual_regression: true
  # config.include Helpers::Components, type: :view
  # config.include ActiveSupport::Testing::TimeHelpers
  # config.include ActionView::Helpers::TagHelper
end
