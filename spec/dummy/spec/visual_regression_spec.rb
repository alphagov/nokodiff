describe "visual regression test runner Percy" do
  it "takes a screenshot of the diff page" do
    visit "/"

    page.percy_snapshot("Test page")
  end
end
