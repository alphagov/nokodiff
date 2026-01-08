# frozen_string_literal: true

require "nokogiri"
require "diff-lcs"

require_relative "nokodiff/version"
require_relative "nokodiff/differ"
require_relative "nokodiff/text_node_diffs"
require_relative "nokodiff/changes_in_fragments"

module Nokodiff
  def self.diff(before_html, after_html)
    html = Differ.new(before_html, after_html).to_html

    if html.respond_to?(:html_safe)
      html.html_safe
    else
      html
    end
  end

  class Error < StandardError; end
  # Your code goes here...
end
