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
      if before_node&.text? || after_node&.text?
        diff_text_node_content(before_node, after_node)
      elsif before_node&.element? || after_node&.element?
        before_children = before_node ? before_node.children.to_a : []
        after_children = after_node ? after_node.children.to_a : []

        max_child_count = [before_children.length, after_children.length].max

        (0..max_child_count).each do |i|
          diff_text_nodes(before_children[i], after_children[i])
        end
      end
    end

    def diff_text_node_content(before_text_node, after_text_node)
      return strong(before_text_node) if text_removed?(before_text_node, after_text_node)
      return strong(after_text_node) if text_added?(before_text_node, after_text_node)

      before_chars = before_text_node.text.chars
      after_chars = after_text_node.text.chars

      diff = Diff::LCS.sdiff(before_chars, after_chars)

      before_fragment, after_fragment = Nokodiff::ChangesInFragments.new(diff).call

      before_text_node.replace(before_fragment)
      after_text_node.replace(after_fragment)
    end

    def text_removed?(before_node, after_node)
      before_node && after_node.nil?
    end

    def text_added?(before_node, after_node)
      before_node.nil? && after_node
    end
  end
end
