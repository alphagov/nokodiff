module Nokodiff
  class Differ
    def initialize(before_html, after_html)
      @before = Nokogiri::HTML.fragment(before_html)
      @after = Nokogiri::HTML.fragment(after_html)
    end

    def to_html
      compared_blocks.map { |diff|
        case diff[:status]
        when :unchanged
          unchanged_block(diff[:before])
        when :changed
          deleted_block(char_diff_html(diff[:before], diff[:after]).first) + added_block(char_diff_html(diff[:before], diff[:after]).last)
        when :deleted
          deleted_block(diff[:before])
        when :added
          added_block(diff[:after])
        end
      }.join("\n")
    end

  private

    def compared_blocks
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
          { status: :added, before: nil, after: after_node }
        end
      end
    end

    def char_diff_html(before_html, after_html)
      before_dup = before_html.dup
      after_dup = after_html.dup
      before_fragment, after_fragment = TextNodeDiffs.new(before_dup, after_dup).call

      merge_adjacent_strong_tags(before_fragment)
      merge_adjacent_strong_tags(after_fragment)

      [before_fragment.to_html, after_fragment.to_html]
    end

    def flush_buffer(fragment, buffer)
      return if buffer.empty?

      fragment.add_child(Nokogiri::XML::Text.new(buffer, fragment))
      buffer.clear
    end

    def wrap_in_strong(char, fragment)
      Nokogiri::XML::Node.new("strong", fragment.document).tap { |n| n.content = char }
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

    def unchanged_block(html)
      html.to_s
    end

    def deleted_block(html)
      %(
        <div class="diff">
           <del>#{html}</del>
        </div>
      )
    end

    def added_block(html)
      %(
        <div class="diff">
           <ins>#{html}</ins>
        </div>
      )
    end
  end
end
