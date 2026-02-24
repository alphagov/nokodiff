# frozen_string_literal: true

require "nokogiri"
require "diff-lcs"

require_relative "nokodiff/formatting_helpers"
require_relative "nokodiff/version"
require_relative "nokodiff/differ"
require_relative "nokodiff/engine"
require_relative "nokodiff/text_node_diffs"
require_relative "nokodiff/changes_in_fragments"
require_relative "nokodiff/html_fragment_validator"

module Nokodiff
  def self.diff(before_html, after_html)
    HTMLFragmentValidator.validate_html!(before_html)
    HTMLFragmentValidator.validate_html!(after_html)

    before = Nokogiri::HTML.fragment(before_html)
    after = Nokogiri::HTML.fragment(after_html)

    html = Differ.new(before, after).to_html
    safe_html(html)
  end

  def self.safe_html(html)
    html.respond_to?(:html_safe) ? html.html_safe : html
  end
end
