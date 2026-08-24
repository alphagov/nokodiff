module Nokodiff
  class TextNodeDiffs
    include FormattingHelpers
    def initialize(before_fragment, after_fragment)
      @before_fragment = before_fragment
      @after_fragment = after_fragment
    end

    def call
      diff_text_nodes(before_fragment, after_fragment)
      [before_fragment, after_fragment]
    end

  private

    attr_accessor :before_fragment, :after_fragment

    def diff_text_nodes(before_node, after_node)
      if text_nodes_or_missing?(before_node, after_node)
        diff_text_node_content(before_node, after_node)
      elsif mixed_text_and_element_nodes(before_node, after_node)
        mark_nodes_as_changed(before_node, after_node)
      elsif before_node&.element? || after_node&.element?
        before_children = before_node ? before_node.children.to_a : []
        after_children = after_node ? after_node.children.to_a : []

        max_child_count = [before_children.length, after_children.length].max

        (0..max_child_count).each do |i|
          diff_text_nodes(before_children[i], after_children[i])
        end
      end
    end

    def text_nodes_or_missing?(before_node, after_node)
      return false unless before_node || after_node

      (before_node.nil? || before_node.text?) && (after_node.nil? || after_node.text?)
    end

    def mixed_text_and_element_nodes(before_node, after_node)
      (before_node&.text? && after_node&.element?) || (before_node&.element? && after_node&.text?)
    end

    def mark_nodes_as_changed(before_node, after_node)
      wrap_node_as_change(before_node)
      wrap_node_as_change(after_node)
    end

    def wrap_node_as_change(node)
      return unless node

      wrapper = Nokogiri::XML::Node.new("span", node.document)
      wrapper["class"] = "diff-marker"

      node.replace(wrapper)
      wrapper.add_child(node)
    end

    def diff_text_node_content(before_text_node, after_text_node)
      before_chars = get_chars(before_text_node)
      after_chars = get_chars(after_text_node)

      diff = Diff::LCS.sdiff(before_chars, after_chars)

      before_fragment, after_fragment = Nokodiff::ChangesInFragments.new(diff).call

      before_text_node&.replace(before_fragment)
      after_text_node&.replace(after_fragment)
    end

    def get_chars(text_node)
      return [] if text_node.nil?

      text_node.text.chars
    end
  end
end
