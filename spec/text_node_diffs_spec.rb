RSpec.describe Nokodiff::TextNodeDiffs do
  describe "#call" do
    context "when called with 'elements' with changes" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello world!</p>"
        after_html = "<p>Goodbye world!</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to have_tag("p") do
          with_tag("span", class: "diff-marker", text: "H")
          with_tag("span", class: "diff-marker", text: "e")
          with_tag("span", class: "diff-marker", text: "l")
          without_tag("span", class: "diff-marker", text: "o")
        end

        expect(after_output.to_xml).to have_tag("p") do
          with_tag("span", class: "diff-marker", text: "G")
          with_tag("span", class: "diff-marker", text: "o")
          with_tag("span", class: "diff-marker", text: "d")
          with_tag("span", class: "diff-marker", text: "b")
          with_tag("span", class: "diff-marker", text: "y")
          with_tag("span", class: "diff-marker", text: "e")
          without_tag("span", class: "diff-marker", text: " ")
        end
      end
    end

    context "when called with 'elements' with deletion" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello world!</p>"
        after_html = "<p>Hello</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to have_tag("p") do
          without_tag("span", class: "diff-marker", text: "H")
          with_tag("span", class: "diff-marker", text: " ")
          with_tag("span", class: "diff-marker", text: "w")
          with_tag("span", class: "diff-marker", text: "r")
          with_tag("span", class: "diff-marker", text: "d")
          with_tag("span", class: "diff-marker", text: "!")
        end

        expect(after_output.to_xml).to have_tag("p") do
          without_tag("span", class: "diff-marker")
        end
      end
    end
    context "when called with 'elements' with addition" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello</p>"
        after_html = "<p>Hello world!</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to have_tag("p") do
          without_tag("span", class: "diff-marker")
        end

        expect(after_output.to_xml).to have_tag("p") do
          without_tag("span", class: "diff-marker", text: "H")
          with_tag("span", class: "diff-marker", text: " ")
          with_tag("span", class: "diff-marker", text: "w")
          with_tag("span", class: "diff-marker", text: "r")
          with_tag("span", class: "diff-marker", text: "d")
          with_tag("span", class: "diff-marker", text: "!")
        end
      end
    end
  end
end
