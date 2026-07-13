# frozen_string_literal: true

module HtmlHelpers
  def normalise_html(html)
    html.gsub(/^[ \t]+/, "")
        .gsub(/[ \t]+/, " ")
        .strip
  end
end

RSpec.configure do |config|
  config.include HtmlHelpers
end
