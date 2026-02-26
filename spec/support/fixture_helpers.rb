module FixtureHelpers
  def load_fixture(name)
    File.read(
      File.join(File.dirname(__FILE__), "..", "fixtures", "html", "#{name}.html"),
    )
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
