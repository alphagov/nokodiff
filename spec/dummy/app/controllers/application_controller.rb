class ApplicationController < ActionController::Base
  def index
    @before = File.read(Rails.root.join("fixtures", "before.html"))
    @after  = File.read(Rails.root.join("fixtures", "after.html"))

    # Call your modified gem logic here
    @diff = Nokodiff.diff(@before, @after)
  end
end
