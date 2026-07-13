module Nokodiff
  module FormattingHelpers
    def highlight_changes(char, fragment)
      Nokogiri::XML::Node.new("span", fragment.document).tap do |n|
        n.content = char
        n["class"] = "diff-marker"
      end
    end

    def insert_change_marker(element, message)
      marker = Nokogiri::XML::Node.new("span", element.document)
      marker.content = "#{message} "
      marker["class"] = "visually-hidden"

      if element.name == "tr"
        element.children.first.prepend_child(marker)
      else
        element.prepend_child(marker)
      end
    end
  end
end
