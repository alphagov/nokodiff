class ChangesInFragments
  def initialize(diff)
    @diff = diff
    @old_fragment = Nokogiri::HTML::DocumentFragment.parse("")
    @new_fragment = Nokogiri::HTML::DocumentFragment.parse("")

    @buffer_old = ""
    @buffer_new = ""
  end

  def call
    @diff.each do |change|
      case change.action
      when "="
        buffer_old << change.old_element
        buffer_new << change.new_element
      when "!"
        emphasise_change(change)
      when "-"
        emphasise_deletion(change)
      when "+"
        emphasise_addition(change)
      end
    end

    flush_buffer(old_fragment, buffer_old)
    flush_buffer(new_fragment, buffer_new)

    [old_fragment, new_fragment]
  end

private

  attr_accessor :old_fragment, :new_fragment, :buffer_old, :buffer_new

  def emphasise_change(change)
    flush_buffer(old_fragment, buffer_old)
    flush_buffer(new_fragment, buffer_new)

    old_fragment.add_child(wrap_in_strong(change.old_element, old_fragment))
    new_fragment.add_child(wrap_in_strong(change.new_element, new_fragment))
  end

  def emphasise_deletion(change)
    flush_buffer(old_fragment, buffer_old)
    old_fragment.add_child(wrap_in_strong(change.old_element, old_fragment))
  end


  def emphasise_addition(change)
    flush_buffer(new_fragment, buffer_new)
    new_fragment.add_child(wrap_in_strong(change.new_element, new_fragment))
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