RSpec.describe Nokodiff::TextNodeDiffs do
  describe "#call" do
    context "when called with 'elements' with changes" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello world!</p>"
        after_html = "<p>Goodbye world!</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to eq(
          "<p><strong>H</strong><strong>e</strong><strong>l</strong><strong>l</strong>o world!</p>",
        )

        expect(after_output.to_xml).to eq(
          "<p><strong>G</strong>o<strong>o</strong><strong>d</strong><strong>b</strong><strong>y</strong><strong>e</strong> world!</p>",
        )
      end
    end

    context "when called with 'elements' with deletion" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello world!</p>"
        after_html = "<p>Hello</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to eq(
          "<p>Hello<strong> </strong><strong>w</strong><strong>o</strong><strong>r</strong><strong>l</strong><strong>d</strong><strong>!</strong></p>",
        )

        expect(after_output.to_xml).to eq(
          "<p>Hello</p>",
        )
      end
    end
    context "when called with 'elements' with addition" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello</p>"
        after_html = "<p>Hello world!</p>"

        before_element = Nokogiri::XML::Document.parse(before_html).element_children.first
        after_element = Nokogiri::XML::Document.parse(after_html).element_children.first

        before_output, after_output = Nokodiff::TextNodeDiffs.new(before_element, after_element).call

        expect(before_output.to_xml).to eq(
          "<p>Hello</p>",
        )

        expect(after_output.to_xml).to eq(
          "<p>Hello<strong> </strong><strong>w</strong><strong>o</strong><strong>r</strong><strong>l</strong><strong>d</strong><strong>!</strong></p>",
        )
      end
    end
  end
end
