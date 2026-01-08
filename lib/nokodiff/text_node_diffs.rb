class TextNodeDiffs
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
    if before_node.text? && after_node.text?
      diff_text_node_content(before_node, after_node)
    elsif before_node.element? && after_node.element?
      before_children = before_node.children.to_a
      after_children = after_node.children.to_a
      max = [before_children.length, after_children.length].max

      (0..max).each do |i|
        before_content = before_children[i]
        after_content = after_children[i]

        next unless before_content && after_content
        diff_text_nodes(before_content, after_content)
      end
    end
  end

  def diff_text_node_content(before_text_node, after_text_node)
    if before_text_node && after_text_node.nil?
      # TODO: need an example which exercises this path
      # raise "in guard requiring wrap in strong"
      before_text_node.replace(wrap_in_strong(before_text_node.to_html, before_text_node.parent))
      return
    end

    if before_text_node.nil? && after_text_node
      # TODO: need an example which exercises this path
      # raise "in guard requiring wrap in strong"
      after_text_node.replace(wrap_in_strong(after_text_node.to_html, after_text_node.parent))
      return
    end

    before_chars = before_text_node.text.chars
    after_chars = after_text_node.text.chars

    diff = Diff::LCS.sdiff(before_chars, after_chars)

    old_fragment, new_fragment = ChangesInFragments.new(diff).call

    before_text_node.replace(old_fragment)
    after_text_node.replace(new_fragment)
  end
end