module Nokodiff
  class Differ
    def initialize(before_html, after_html)
      @before = Nokogiri::HTML.fragment(before_html)
      @after = Nokogiri::HTML.fragment(after_html)
    end

    def to_html
      compare_blocks.map { |diff|
        case diff[:status]
        when :unchanged
          diff[:before]
        when :changed
          %(
        <div class="diff">
           <del>#{char_diff_html(diff[:before], diff[:after]).first}</del>
        </div>
        <div class="diff">
            <ins>#{char_diff_html(diff[:before], diff[:after]).last}</ins>
        </div>
        )
        when :deleted
          %(
        <div class="diff">
          <del>#{diff[:before]}</del>
        </div>
        )
        when :added
          %(
        <div class="diff">
          <ins>#{diff[:after]}</ins>
        </div>
        )
        end
      }.join("\n")
    end

  private

    def compare_blocks
      before_nodes = @before.children.to_a
      after_nodes = @after.children.to_a

      max = [before_nodes.length, after_nodes.length].max

      max.times.map do |i|
        before_node = before_nodes[i]
        after_node = after_nodes[i]

        if before_node && after_node
          if before_node.to_html.strip == after_node.to_html.strip
            { status: :unchanged, before: before_node, after: after_node }
          else
            { status: :changed, before: before_node, after: after_node }
          end
        elsif before_node
          { status: :deleted, before: before_node, after: nil }
        elsif after_node
          { status: :deleted, before: nil, after: after_node }
        end
      end
    end

    def char_diff_html(old_html, new_html)
      old_fragment = old_html.dup
      new_fragment = new_html.dup

      diff_text_nodes(old_fragment, new_fragment)

      merge_adjacent_strong_tags(old_fragment)
      merge_adjacent_strong_tags(new_fragment)

      [old_fragment.to_html, new_fragment.to_html]
    end

    def diff_text_nodes(old_node, new_node)
      if old_node.text? && new_node.text?
        diff_text_node_content(old_node, new_node)
      elsif old_node.element? && new_node.element?
        old_children = old_node.children.to_a
        new_children = new_node.children.to_a
        max = [old_children.length, new_children.length].max

        (0..max).each do |i|
          original = old_children[i]
          new = new_children[i]

          next unless original && new

          diff_text_nodes(original, new)
        end
      end
    end

    def diff_text_node_content(old_text_node, new_text_node)
      old_chars = old_text_node.text.chars
      new_chars = new_text_node.text.chars

      diff = Diff::LCS.sdiff(old_chars, new_chars)

      old_fragment = Nokogiri::HTML::DocumentFragment.parse("")
      new_fragment = Nokogiri::HTML::DocumentFragment.parse("")

      buffer_old = ""
      buffer_new = ""

      diff.each do |change|
        case change.action
        when "="
          buffer_old << change.old_element
          buffer_new << change.new_element
        when "!"
          old_fragment.add_child(Nokogiri::XML::Text.new(buffer_old, old_fragment)) unless buffer_old.empty?
          new_fragment.add_child(Nokogiri::XML::Text.new(buffer_new, new_fragment)) unless buffer_new.empty?
          buffer_old = ""
          buffer_new = ""

          old_fragment.add_child(Nokogiri::XML::Node.new("strong", old_fragment.document).tap { |n| n.content = change.old_element })
          new_fragment.add_child(Nokogiri::XML::Node.new("strong", new_fragment.document).tap { |n| n.content = change.new_element })
        when "-"
          old_fragment.add_child(Nokogiri::XML::Text.new(buffer_old, old_fragment)) unless buffer_old.empty?
          buffer_old = ""
          old_fragment.add_child(Nokogiri::XML::Node.new("strong", old_fragment.document).tap { |n| n.content = change.old_element })
        when "+"
          new_fragment.add_child(Nokogiri::XML::Text.new(buffer_new, new_fragment)) unless buffer_new.empty?
          buffer_new = ""
          new_fragment.add_child(Nokogiri::XML::Node.new("strong", new_fragment.document).tap { |n| n.content = change.new_element })
        end
      end

      old_fragment.add_child(Nokogiri::XML::Text.new(buffer_old, old_fragment)) unless buffer_old.empty?
      new_fragment.add_child(Nokogiri::XML::Text.new(buffer_new, new_fragment)) unless buffer_new.empty?

      old_text_node.replace(old_fragment)
      new_text_node.replace(new_fragment)
    end

    def merge_adjacent_strong_tags(node)
      return unless node.element?

      node.children.each do |child|
        merge_adjacent_strong_tags(child) if child.element?
      end

      node.children.each_cons(2) do |left, right|
        next unless left.name == "strong" && right.name == "strong"

        left.content = left.content + right.content
        right.remove

        merge_adjacent_strong_tags(node)
        break
      end
    end
  end
end
