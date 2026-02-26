RSpec.describe Nokodiff::HTMLFragment do
  describe "#initialize" do
    it "allows nil as an input" do
      expect {
        Nokodiff::HTMLFragment.new(nil)
      }.not_to raise_error
    end

    it "allows '' as an input" do
      expect {
        Nokodiff::HTMLFragment.new("")
      }.not_to raise_error
    end

    it "allows HTML comments within an input" do
      expect {
        Nokodiff::HTMLFragment.new("<!-- hello --><p>html snippet</p>")
      }.not_to raise_error
    end

    it "raises an argument error when passed non html arguments" do
      expect {
        Nokodiff::HTMLFragment.new("just text")
      }.to raise_error(Nokodiff::HTMLFragment::InvalidHTMLError)
    end

    it "raises an argument error when passed malformed HTML" do
      invalid_html = "<<p> /p>"

      expect {
        Nokodiff::HTMLFragment.new(invalid_html)
      }.to raise_error(Nokodiff::HTMLFragment::InvalidHTMLError)
    end

    it "raises an argument error when passed preprocessing instructions" do
      invalid_html = '<?xml version="1.0"?><div></div>'

      expect {
        Nokodiff::HTMLFragment.new(invalid_html)
      }.to raise_error(Nokodiff::HTMLFragment::InvalidHTMLError)
    end

    it "removes any blank nodes" do
      html = <<~HTML
        <p>Hello world!</p>


        <p>Goodbye world!</p>
      HTML

      fragment = Nokodiff::HTMLFragment.new(html)
      expect(fragment.to_html).to eq("<p>Hello world!</p><p>Goodbye world!</p>")
    end

    it "removes any comments" do
      html = <<~HTML
        <p>Hello world!</p>
        <!-- comment -->
        <p>Goodbye world!</p>
      HTML

      fragment = Nokodiff::HTMLFragment.new(html)
      expect(fragment.to_html).to eq("<p>Hello world!</p><p>Goodbye world!</p>")
    end
  end

  describe "forwardable methods" do
    let(:html) { "<p>Hello world!</p>" }
    let(:fragment) { Nokodiff::HTMLFragment.new(html) }

    describe "#children" do
      it "delegates to the underlying Nokogiri fragment" do
        expect(fragment.children.first.text).to eq("Hello world!")
      end
    end

    describe "#css" do
      it "delegates to the underlying Nokogiri fragment" do
        expect(fragment.css("p").first.text).to eq("Hello world!")
      end
    end

    describe "#at" do
      it "delegates to the underlying Nokogiri fragment" do
        expect(fragment.at("p").text).to eq("Hello world!")
      end
    end

    describe "#to_html" do
      it "delegates to the underlying Nokogiri fragment" do
        expect(fragment.to_html).to eq(html)
      end
    end
  end
end
