class ApplicationController < ActionController::Base
  def index
    @before = "<p> test </p>\n<p> moved para </p>"
    @after  = "<p> test </p>\n<p> added tag </p>\n<p> moved para </p>"

    # Call your modified gem logic here
    @diff = Nokodiff.diff(@before, @after)
  end
end
