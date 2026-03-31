# frozen_string_literal: true

require "nokogiri"
require "diff-lcs"
require "byebug"

require_relative "nokodiff/formatting_helpers"
require_relative "nokodiff/version"
require_relative "nokodiff/differ"
require_relative "nokodiff/engine"
require_relative "nokodiff/text_node_diffs"
require_relative "nokodiff/changes_in_fragments"
require_relative "nokodiff/html_fragment"

module Nokodiff
  def self.diff(before_html, after_html)
    before = Nokodiff::HTMLFragment.new(before_html)
    after = Nokodiff::HTMLFragment.new(after_html)

    before_nodes, after_nodes = nodes(before, after)
    keys = (before_nodes.keys + after_nodes.keys).uniq

    html = keys.any? ? diff_by_keys(after, keys, before_nodes, after_nodes) : Differ.new(before, after).to_html
    safe_html(html)
  end

  def self.safe_html(html)
    html.respond_to?(:html_safe) ? html.html_safe : html
  end

  private_class_method def self.nodes(before, after)
    [
      fetch_diff_nodes(before),
      fetch_diff_nodes(after),
    ]
  end

  private_class_method def self.fetch_diff_nodes(fragment)
    fragment.css("[data-diff-key]").map { |node| [node["data-diff-key"], node] }.to_h
  end

  private_class_method def self.diff_by_keys(after, keys, before_nodes, after_nodes)
    keys.each do |key|
      diff = Differ.new(
        before_nodes.fetch(key, Nokogiri::HTML.fragment("")),
        after_nodes.fetch(key, Nokogiri::HTML.fragment("")),
      ).to_html
      after.at("[data-diff-key='#{key}']")&.inner_html = diff
    end
    after.to_html
  end
end
