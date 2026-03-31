module Nokodiff
  module FormattingHelpers
    def highlight_changes(char, fragment)
      Nokogiri::XML::Node.new("span", fragment.document).tap do |n|
        n.content = char
        n["class"] = "diff-marker"
      end
    end
  end
end
