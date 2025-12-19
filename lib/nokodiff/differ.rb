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
           <del>#{diff[:before].to_html}</del>
        </div>
        <div class="diff">
            <ins>#{diff[:after].to_html}</ins>
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
  end
end
