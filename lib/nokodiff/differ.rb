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
          deleted_block(diff[:before]) + added_block(diff[:after])
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
