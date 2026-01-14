module Nokodiff
  module FormattingHelpers
    def wrap_in_strong(char, fragment)
      Nokogiri::XML::Node.new("strong", fragment.document).tap { |n| n.content = char }
    end

    def strong(text_node)
      text_node.replace(wrap_in_strong(text_node.to_html, text_node.parent))
    end
  end
end
