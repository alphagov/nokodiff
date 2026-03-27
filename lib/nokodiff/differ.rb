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
          changed_block(diff[:before], diff[:after])
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
      align_nodes(before_nodes, after_nodes)
    end

    SIMILARITY_THRESHOLD = 0.3

    def align_nodes(before_nodes, after_nodes)
      n = before_nodes.length
      m = after_nodes.length

      sim = Array.new(n) { |i| Array.new(m) { |j| node_similarity(before_nodes[i], after_nodes[j]) } }

      dp = Array.new(n + 1) { Array.new(m + 1, 0.0) }
      (1..n).each do |i|
        (1..m).each do |j|
          dp[i][j] = [
            dp[i - 1][j - 1] + sim[i - 1][j - 1],
            dp[i - 1][j],
            dp[i][j - 1],
          ].max
        end
      end

      result = []
      i, j = n, m
      while i > 0 || j > 0
        if i > 0 && j > 0 && sim[i - 1][j - 1] > 0 &&
            (dp[i][j] - (dp[i - 1][j - 1] + sim[i - 1][j - 1])).abs < 1e-9
          bn, an = before_nodes[i - 1], after_nodes[j - 1]
          status = bn.to_html.strip == an.to_html.strip ? :unchanged : :changed
          result.unshift({ status: status, before: bn, after: an })
          i -= 1
          j -= 1
        elsif i > 0 && (dp[i][j] - dp[i - 1][j]).abs < 1e-9
          result.unshift({ status: :deleted, before: before_nodes[i - 1], after: nil })
          i -= 1
        else
          result.unshift({ status: :added, before: nil, after: after_nodes[j - 1] })
          j -= 1
        end
      end

      result
    end

    def node_similarity(before_node, after_node)
      before_html = before_node.to_html.strip
      after_html = after_node.to_html.strip

      return 1.0 if before_html == after_html

      if before_node.element? && after_node.element?
        return 0.0 unless before_node.name == after_node.name

        before_text = before_node.text.strip
        after_text = after_node.text.strip
        max_len = [before_text.length, after_text.length].max
        return 0.1 if max_len == 0

        lcs_len = Diff::LCS.lcs(before_text.chars, after_text.chars).length
        [lcs_len.to_f / max_len, 0.1].max
      elsif before_node.text? && after_node.text?
        before_text = before_node.text.strip
        after_text = after_node.text.strip
        max_len = [before_text.length, after_text.length].max
        return 1.0 if max_len == 0
        return 0.0 if before_text.empty? || after_text.empty?

        lcs_len = Diff::LCS.lcs(before_text.chars, after_text.chars).length
        [lcs_len.to_f / max_len, 0.1].max
      else
        0.0
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

    def changed_block(before_node, after_node)
      if structurally_similar?(before_node, after_node)
        inner_diff = Differ.new(before_node, after_node).to_html
        rebuild_element(after_node, inner_diff)
      elsif before_node.text? && after_node.text?
        before_diff, after_diff = text_node_char_diff(before_node, after_node)
        deleted_inline(before_diff) + added_inline(after_diff)
      else
        before_diff, after_diff = char_diff_html(before_node, after_node)
        deleted_block(before_diff) + added_block(after_diff)
      end
    end

    def structurally_similar?(before_node, after_node)
      before_node.element? && after_node.element? && before_node.name == after_node.name
    end

    def rebuild_element(template_node, inner_html)
      result = template_node.dup
      result.inner_html = inner_html
      result.to_html
    end

    def text_node_char_diff(before_text, after_text)
      diff = Diff::LCS.sdiff(before_text.text.chars, after_text.text.chars)
      before_fragment, after_fragment = Nokodiff::ChangesInFragments.new(diff).call
      [merge_fragment_spans(before_fragment), merge_fragment_spans(after_fragment)]
    end

    def merge_fragment_spans(fragment)
      doc = fragment.document
      wrapper = Nokogiri::XML::Node.new("span", doc)
      wrapper.inner_html = fragment.to_html
      merge_adjacent_highlighted_changes(wrapper)
      wrapper.inner_html
    end

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

    def deleted_inline(html)
      %(<del aria-label="removed content">#{html}</del>)
    end

    def added_inline(html)
      %(<ins aria-label="added content">#{html}</ins>)
    end

  end
end
