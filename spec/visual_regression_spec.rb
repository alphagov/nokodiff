require "spec_helper"
require "percy/capybara"
require "uri"

RSpec.describe "Visual regression" do
  describe "visual regression test runner Percy", :visual_regression do
    it "takes a screenshot of the test page" do
      visit root_path

      page.percy_snapshot("Test page")
    end
  end
end
