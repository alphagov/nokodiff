module Nokodiff
  module FormattingHelpers
    def wrap_character_as_change(char, fragment)
      Nokogiri::XML::Node.new("span", fragment.document).tap do |n|
        n.content = char
        n["class"] = "diff-marker"
      end
    end

    def wrap_node_as_change(node)
      return unless node

      wrapper = Nokogiri::XML::Node.new("span", node.document)
      wrapper["class"] = "diff-marker"

      node.replace(wrapper)
      wrapper.add_child(node)
    end

    def insert_table_row_change_marker(element, message)
      marker = Nokogiri::XML::Node.new("span", element.document)
      marker.content = "#{message} "
      marker["class"] = "visually-hidden"

      element.children.first.prepend_child(marker)
    end
  end
end
