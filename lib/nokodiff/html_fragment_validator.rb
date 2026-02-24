module Nokodiff
  module HTMLFragmentValidator
  module_function

    def validate_html!(html)
      document = Nokogiri::HTML::DocumentFragment.parse(html)

      invalid_text_nodes = document.children.reject do |node|
        node.element? || node.comment? || (node.text? && node.text.strip.empty?)
      end

      unless invalid_text_nodes.empty?
        raise ArgumentError, "Invalid HTML input"
      end

      document
    end
  end
end
