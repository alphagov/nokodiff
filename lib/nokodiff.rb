# frozen_string_literal: true

require "nokogiri"
require "diff-lcs"

require_relative "nokodiff/formatting_helpers"
require_relative "nokodiff/version"
require_relative "nokodiff/differ"
require_relative "nokodiff/text_node_diffs"
require_relative "nokodiff/changes_in_fragments"

module Nokodiff
  def self.diff(before_html, after_html)
    HTMLFragmentValidator.validate_html!(before_html)
    HTMLFragmentValidator.validate_html!(after_html)

    html = Differ.new(before_html, after_html).to_html
    safe_html(html)
  end

  def self.safe_html(html)
    html.respond_to?(:html_safe) ? html.html_safe : html
  end

  class Error < StandardError; end

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
