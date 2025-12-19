# frozen_string_literal: true

require "nokogiri"
require "diff-lcs"

require_relative "nokodiff/version"
require_relative "nokodiff/differ"

module Nokodiff
  def self.diff(before_html, after_html)
    Differ.new(before_html, after_html).to_html
  end

  class Error < StandardError; end
  # Your code goes here...
end
