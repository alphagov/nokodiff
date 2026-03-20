module Nokodiff
  class Differ
    def initialize(before, after)
      @before = before
      @after = after
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
      before_nodes = @before.children.to_a.map { |n| ComparableNode.new(n) }
      after_nodes = @after.children.to_a.map { |n| ComparableNode.new(n) }

      Diff::LCS.sdiff(before_nodes, after_nodes).map do |change|
        case change.action
        when "="
          { status: :unchanged, before: change.old_element.node, after: change.new_element.node }
        when "!"
          { status: :changed, before: change.old_element.node, after: change.new_element.node }
        when "-"
          { status: :deleted, before: change.old_element.node, after: nil }
        when "+"
          { status: :added, before: nil, after: change.new_element.node }
        end
      end
    end

    class ComparableNode
      attr_reader :node, :html

      def initialize(node)
        @node = node
        @html = node.to_html.strip
      end

      def ==(other)
        other.is_a?(ComparableNode) && html == other.html
      end

      def eql?(other)
        self == other
      end

      def hash
        html.hash
      end
    end

    # def compared_blocks
    #   before_nodes = @before.children.to_a
    #   after_nodes = @after.children.to_a
    #
    #   max = [before_nodes.length, after_nodes.length].max
    #
    #   max.times.map do |i|
    #     before_node = before_nodes[i]
    #     after_node = after_nodes[i]
    #
    #     set_change_status(before_node, after_node)
    #   end
    # end

    def char_diff_html(before_html, after_html)
      before_dup = before_html.dup
      after_dup = after_html.dup

      before_fragment, after_fragment = Nokodiff::TextNodeDiffs.new(before_dup, after_dup).call

      merge_adjacent_highlighted_changes(before_fragment)
      merge_adjacent_highlighted_changes(after_fragment)

      [before_fragment.to_html, after_fragment.to_html]
    end

    def merge_adjacent_highlighted_changes(node)
      return unless node.element?

      node.children.each do |child|
        merge_adjacent_highlighted_changes(child) if child.element?
      end

      node.children.each_cons(2) do |left, right|
        next unless node_is_a_change?(left) && node_is_a_change?(right)

        left.content = left.content + right.content
        right.remove

        merge_adjacent_highlighted_changes(node)
        break
      end
    end

    def node_is_a_change?(node)
      node.name == "span" && node["class"] == "diff-marker"
    end

    def unchanged_block(html)
      html.to_s
    end

    def deleted_block(html)
      %(
        <div class="diff">
           <del aria-label="removed content">#{html}</del>
        </div>
      )
    end

    def added_block(html)
      %(
        <div class="diff">
           <ins aria-label="added content">#{html}</ins>
        </div>
      )
    end

    class ComparableNode
      attr_reader :node, :html

      def initialize(node)
        @node = node
        @html = node.to_html.strip
      end

      def ==(other)
        other.is_a?(ComparableNode) && html == other.html
      end

      def eql?(other)
        self == other
      end

      def hash
        html.hash
      end
    end
  end
end
