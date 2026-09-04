# require "spec/dummy/test/spec_helper"
# require "spec_helper"
require "./spec/dummy/test/rails_helper"
require "percy/capybara"
# require "capybara"
# require "uri"
require "nokodiff/engine"

RSpec.describe "Visual regression" do
  # include Engine.routes.url_helpers
  # include Rails.application.routes.url_helpers
  # include Engine.routes.url_helpers

  # setup do
  #   @routes = Engine.routes
  # end

  describe "visual regression test runner Percy", :visual_regression do
    it "takes a screenshot of the test page" do
      visit root_path

      page.percy_snapshot("Test page")
    end
  end
end
