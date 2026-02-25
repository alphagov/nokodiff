require "forwardable"

module Nokodiff
  class HTMLFragment
    extend Forwardable

    def initialize(html)
      @fragment = Nokogiri::HTML.fragment(html)
      validate!
    end

    def_delegators :@fragment, :children, :css, :at, :to_html

  private

    def validate!
      invalid_text_nodes = @fragment.children.reject do |node|
        node.element? || node.comment? || (node.text? && node.text.strip.empty?)
      end

      unless invalid_text_nodes.empty?
        raise ArgumentError, "Invalid HTML input"
      end
    end
  end
end
