ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

require "rspec/rails"
require "capybara/rails"
require "govuk_test"
require "percy/capybara"

GovukTest.configure

RSpec.configure do |config|
  config.include Capybara::DSL, capybara: true, visual_regression: true
  config.before { Capybara.current_driver = Capybara.javascript_driver }
end
