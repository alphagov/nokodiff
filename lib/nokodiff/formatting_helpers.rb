module Nokodiff
  module FormattingHelpers
    def highlight_changes(char, fragment)
      Nokogiri::XML::Node.new("span", fragment.document).tap do |n|
        n.content = char
        n["class"] = "diff-marker"
      end
    end

    def highlighted_change(text_node)
      text_node.replace(highlight_changes(text_node.to_html, text_node.parent))
    end
  end
end
