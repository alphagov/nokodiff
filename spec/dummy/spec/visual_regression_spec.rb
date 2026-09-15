RSpec.describe "Visual regression" do
  describe "visual regression test runner Percy", :visual_regression do
    it "takes a screenshot of the test page" do
      visit "/"

      page.percy_snapshot("Test page")
    end
  end
end
