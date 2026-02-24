module Nokodiff
  module HTMLFragmentValidator
  module_function

    def validate_html!(html)
      document = Nokogiri::HTML::DocumentFragment.parse(html)

      invalid_text_nodes = document.children.select do |node|
        if node.element?
          false
        elsif node.comment?
          false
        elsif node.text?
          !node.text.strip.empty?
        else
          true
        end
      end

      unless invalid_text_nodes.empty?
        raise ArgumentError, "Invalid HTML input"
      end

      document
    end
  end
end
