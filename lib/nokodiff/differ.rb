module Nokodiff
  class Differ
    include FormattingHelpers

    BOTTOM_LEVEL_ELEMENTS = %w[p li tr h1 h2 h3 h4 h5 h6].freeze

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
          diff[:before].text? ? build_deleted_text_html(diff[:before]) : build_deleted_element_html(diff[:before])
        when :added
          diff[:after].text? ? build_added_text_html(diff[:after]) : build_added_element_html(diff[:after])
        end
      }.join("\n")
    end

  private

    def compared_blocks
      before_nodes = @before.children.to_a
      after_nodes = @after.children.to_a

      before_html_strings = before_nodes.map { |n| n.to_html.strip }
      after_html_strings  = after_nodes.map { |n| n.to_html.strip }

      Diff::LCS.sdiff(before_html_strings, after_html_strings).map do |change|
        case change.action
        when "="
          {
            status: :unchanged,
            before: before_nodes[change.old_position],
            after: after_nodes[change.new_position],
          }
        when "!"
          {
            status: :changed,
            before: before_nodes[change.old_position],
            after: after_nodes[change.new_position],
          }
        when "-"
          {
            status: :deleted,
            before: before_nodes[change.old_position],
            after: nil,
          }
        when "+"
          {
            status: :added,
            before: nil,
            after: after_nodes[change.new_position],
          }
        end
      end
    end

    def changed_block(before_node, after_node)
      if structurally_similar?(before_node, after_node) && !treat_element_as_single_change?(before_node)
        inner_diff = Differ.new(before_node, after_node).to_html
        rebuild_element(after_node, inner_diff)
      elsif both_text_nodes?(before_node, after_node)
        before_node, after_node = diff_raw_text(before_node, after_node)
        build_deleted_text_html(before_node) + build_added_text_html(after_node)
      else
        before_node, after_node = diff_sub_elements(before_node, after_node)
        build_deleted_element_html(before_node) + build_added_element_html(after_node)
      end
    end

    def both_text_nodes?(before_node, after_node)
      before_node.text? && after_node.text?
    end

    def structurally_similar?(before_node, after_node)
      before_node.element? &&
        after_node.element? &&
        before_node.name == after_node.name
    end

    # We want to treat all content within certain elements as single changes, even if they are structurally different,
    # to avoid overwhelming the user with changes, and ensure any nested elements are included within the diff,
    # rather than being treated as added or removed content on their own.
    def treat_element_as_single_change?(before_node)
      BOTTOM_LEVEL_ELEMENTS.include?(before_node.name)
    end

    def rebuild_element(template_node, inner_html)
      result = template_node.dup
      result.inner_html = inner_html
      result.to_html
    end

    def diff_raw_text(before_text, after_text)
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

    def diff_sub_elements(before_html, after_html)
      before_fragment = before_html.dup
      after_fragment = after_html.dup

      Nokodiff::TextNodeDiffs.new(before_fragment, after_fragment).call

      merge_adjacent_highlighted_changes(before_fragment)
      merge_adjacent_highlighted_changes(after_fragment)

      [before_fragment, after_fragment]
    end

    def merge_adjacent_highlighted_changes(node)
      return unless node.element?

      node.children.each do |child|
        merge_adjacent_highlighted_changes(child) if child.element?
      end

      node.children.each_cons(2) do |left, right|
        next unless node_is_a_change?(left) && node_is_a_change?(right)

        right.children.to_a.each { |child| left.add_child(child) }
        right.remove

        merge_adjacent_highlighted_changes(node)
        break
      end
    end

    def node_is_a_change?(node)
      node.name == "span" && node["class"] == "diff-marker"
    end

    def unchanged_block(node)
      node.to_html
    end

    def build_deleted_text_html(html)
      <<~HTML
        <span class="diff del">
          <span class="visually-hidden">Removed content </span>
          #{html}
        </span>
      HTML
    end

    def build_added_text_html(html)
      <<~HTML
        <span class="diff ins">
          <span class="visually-hidden">Added content </span>
          #{html}
        </span>
      HTML
    end

    def build_added_element_html(element)
      if element.name == "tr"
        insert_table_row_change_marker(element, "Added row")
        class_string = "#{element['class']&.gsub('del', '')} diff ins".strip

        <<~HTML
          <#{element.name} class="#{class_string}">
             #{element.inner_html}
          </#{element.name}>
        HTML

      else
        # Entirely new steps OLs require that the div also have the .steps class
        # This is either a bug or weakness in the actual govuk CSS for that class
        class_string = element["class"].nil? ? nil : " class= \"#{element['class']}\""
        span_class_string = element["class"]&.include?("steps") ? "diff ins steps" : "diff ins"

        <<~HTML
          <#{element.name}#{class_string}>
            <span class="#{span_class_string}">
              <span class="visually-hidden">Added content </span>
              #{element.inner_html}
            </span>
          </#{element.name}>
        HTML
      end
    end

    def build_deleted_element_html(element)
      if element.name == "tr"
        insert_table_row_change_marker(element, "Removed row")
        class_string = "#{element['class']&.gsub('ins', '')} diff del".strip

        <<~HTML
          <#{element.name} class="#{class_string}">
             #{element.inner_html}
          </#{element.name}>
        HTML

      else
        # Entirely removed steps OLs require that the span also have the .steps class
        # This is either a bug or weakness in the actual govuk CSS for that class
        class_string = element["class"].nil? ? nil : " class= \"#{element['class']}\""
        span_class_string = element["class"]&.include?("steps") ? "diff del steps" : "diff del"

        <<~HTML
          <#{element.name}#{class_string}>
            <span class="#{span_class_string}">
              <span class="visually-hidden">Removed content </span>
              #{element.inner_html}
            </span>
          </#{element.name}>
        HTML
      end
    end
  end
end
