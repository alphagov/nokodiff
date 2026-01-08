RSpec.describe TextNodeDiffs do
  describe "#call" do
    context "when called with 'elements' with changes" do
      it "returns an HTML diff with every changed character individually wrapped" do
        before_html = "<p>Hello world!</p>"
        after_html = "<p>Goodbye world!</p>"

        before_element = Nokogiri::XML::Node.new(before_html, Nokogiri::XML::Document.new)
        after_element = Nokogiri::XML::Node.new(after_html, Nokogiri::XML::Document.new)

        before_output, after_output = TextNodeDiffs.new(before_element, after_element).call

        expect(before_output).to eq(
          "<p><strong>H</strong><strong>e</strong><strong>l</strong><strong>l</strong>o world!</p>"
        )

        expect(after_output).to eq(
          "<p><strong>G</strong>o<strong>o</strong><strong>d</strong><strong>b</strong><strong>y</strong><strong>e</strong> world!</p>"
        )
      end

    end
  end
end