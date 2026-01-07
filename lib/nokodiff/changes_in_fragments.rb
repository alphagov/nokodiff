module Nokodiff
  class ChangesInFragments
    include FormattingHelpers
    def initialize(diff)
      @diff = diff
      @before_fragment = Nokogiri::HTML::DocumentFragment.parse("")
      @after_fragment = Nokogiri::HTML::DocumentFragment.parse("")

      @accumulated_before_text = ""
      @accumulated_after_text = ""
    end

    def call
      @diff.each do |change|
        case change.action
        when "="
          no_change_emphasis(change)
        when "!"
          emphasise_change(change)
        when "-"
          emphasise_deletion(change)
        when "+"
          emphasise_addition(change)
        end
      end

      append_accumulated_text(before_fragment, accumulated_before_text)
      append_accumulated_text(after_fragment, accumulated_after_text)

      [before_fragment, after_fragment]
    end

  private

    attr_accessor :before_fragment, :after_fragment, :accumulated_before_text, :accumulated_after_text

    def no_change_emphasis(change)
      accumulated_before_text << change.old_element
      accumulated_after_text << change.new_element
    end

    def emphasise_change(change)
      append_accumulated_text(before_fragment, accumulated_before_text)
      append_accumulated_text(after_fragment, accumulated_after_text)

      before_fragment.add_child(wrap_in_strong(change.old_element, before_fragment))
      after_fragment.add_child(wrap_in_strong(change.new_element, after_fragment))
    end

    def emphasise_deletion(change)
      append_accumulated_text(before_fragment, accumulated_before_text)
      before_fragment.add_child(wrap_in_strong(change.old_element, before_fragment))
    end

    def emphasise_addition(change)
      append_accumulated_text(after_fragment, accumulated_after_text)
      after_fragment.add_child(wrap_in_strong(change.new_element, after_fragment))
    end

    def append_accumulated_text(fragment, accumulated_text)
      return if accumulated_text.empty?

      fragment.add_child(Nokogiri::XML::Text.new(accumulated_text, fragment))
      accumulated_text.clear
    end
  end
end
