class ChangesInFragments
  def initialize(diff)
    @diff = diff
    @before_fragment = Nokogiri::HTML::DocumentFragment.parse("")
    @after_fragment = Nokogiri::HTML::DocumentFragment.parse("")

    @buffer_before = ""
    @buffer_after = ""
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

    flush_buffer(before_fragment, buffer_before)
    flush_buffer(after_fragment, buffer_after)

    [before_fragment, after_fragment]
  end

private

  attr_accessor :before_fragment, :after_fragment, :buffer_before, :buffer_after

  def no_change_emphasis(change)
    buffer_before << change.old_element
    buffer_after << change.new_element
  end

  def emphasise_change(change)
    flush_buffer(before_fragment, buffer_before)
    flush_buffer(after_fragment, buffer_after)

    before_fragment.add_child(wrap_in_strong(change.old_element, before_fragment))
    after_fragment.add_child(wrap_in_strong(change.new_element, after_fragment))
  end

  def emphasise_deletion(change)
    flush_buffer(before_fragment, buffer_before)
    before_fragment.add_child(wrap_in_strong(change.old_element, before_fragment))
  end

  def emphasise_addition(change)
    flush_buffer(after_fragment, buffer_after)
    after_fragment.add_child(wrap_in_strong(change.new_element, after_fragment))
  end

  def flush_buffer(fragment, buffer)
    return if buffer.empty?

    fragment.add_child(Nokogiri::XML::Text.new(buffer, fragment))
    buffer.clear
  end

  def wrap_in_strong(char, fragment)
    Nokogiri::XML::Node.new("strong", fragment.document).tap { |n| n.content = char }
  end
end
