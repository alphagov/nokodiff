module Nokodiff
  module FormattingHelpers
    def wrap_in_strong(char, fragment)
      if char.length == 1 && char.match?("\n")
        char
      else
        Nokogiri::XML::Node.new("strong", fragment.document).tap { |n| n.content = char }
      end
    end

    def strong(text_node)
      text_node.replace(wrap_in_strong(text_node.to_html, text_node.parent))
    end
  end
end
