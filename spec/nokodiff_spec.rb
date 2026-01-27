# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
  end

  describe ".diff" do
    it "allows nil as an input" do
      expect {
        Nokodiff.diff("<p>html snippet</p>", nil)
      }.not_to raise_error
    end

    it "allows '' as an input" do
      expect {
        Nokodiff.diff("<p>html snippet</p>", "")
      }.not_to raise_error
    end

    it "allows HTML comments within an input" do
      expect {
        Nokodiff.diff("<!-- hello --><p>html snippet</p>", "")
      }.not_to raise_error
    end

    it "raises an argument error if only one block is given" do
      expect {
        Nokodiff.diff("just text")
      }.to raise_error(ArgumentError)
    end

    it "does not raise an argument error when two blocks are given" do
      expect {
        Nokodiff.diff("<p>block one</p>", "<p>block two</p>")
      }.not_to raise_error
    end

    it "raises an argument error when passed non html arguments" do
      expect {
        Nokodiff.diff("just text", "<p>html snippet</p>")
      }.to raise_error(ArgumentError)
    end

    it "raises an argument error when passed malformed HTML" do
      invalid_html = "<<p> /p>"

      expect {
        Nokodiff.diff(invalid_html, "<p>html snippet</p>")
      }.to raise_error(ArgumentError)
    end

    it "raises an argument error when passed preprocessing instructions" do
      invalid_html = '<?xml version="1.0"?><div></div>'

      expect {
        Nokodiff.diff(invalid_html, "<p>html snippet</p>")
      }.to raise_error(ArgumentError)
    end
  end

  describe ".safe_html" do
    before { stub_const("Differ", Class.new) }

    it "returns html_safe when html responds to html_safe" do
      fake_html = double("fake html")

      allow(fake_html).to receive(:respond_to?).with(:html_safe).and_return(true)
      allow(fake_html).to receive(:html_safe).and_return("html_safe version")

      result = described_class.safe_html(fake_html)

      expect(result).to eq("html_safe version")
    end

    it "returns the original object when html_safe is not available" do
      fake_html = double("fake html")

      allow(fake_html).to receive(:respond_to?).with(:html_safe).and_return(false)

      result = described_class.safe_html(fake_html)

      expect(result).to eq(fake_html)
    end
  end

  describe "#to_html" do
    context "when flat text nodes" do
      describe "are unchanged" do
        it "returns unchanged html" do
          html = "<p>Hello world!</p>"

          result = Nokodiff.diff(html, html)

          expect(result).to include("<p>Hello world!</p>")
          expect(result).not_to include('<div class="diff">')
          expect(result).not_to include('<del aria-label="removed content">')
          expect(result).not_to include('<ins aria-label="added content">')
        end
      end

      describe "are changed" do
        it "wraps changed blocks in del and ins tags" do
          before_html = "<p>Hello world!</p>"
          after_html = "<p>Goodbye world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include('<del aria-label="removed content"><p><strong>Hell</strong>o world!</p></del>')
          expect(result).to include('<ins aria-label="added content"><p><strong>G</strong>o<strong>odbye</strong> world!</p></ins>')
        end
      end

      describe "are deleted" do
        it "handles completely deleting content" do
          before_html = "<p>Hello world!</p>"
          after_html = ""

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include('<del aria-label="removed content"><p>Hello world!</p></del>')
          expect(result).not_to include('<ins aria-label="added content">')
        end
      end

      describe "are added" do
        it "handles adding entirely new content" do
          before_html = ""
          after_html = "<p>Hello world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).not_to include('<del aria-label="removed content">')
          expect(result).to include('<ins aria-label="added content"><p>Hello world!</p></ins>')
        end
      end
    end

    context "links" do
      it "diffs changed link text" do
        before_html = <<~HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link A</a></li>
              </ul>
          </div>
        HTML

        after_html = <<~HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        output = Nokodiff.diff(before_html, after_html)

        expect(output).to include('<li><a href="https://a.example.com">Link <strong>A</strong></a></li>')
        expect(output).to include('<li><a href="https://a.example.com">Link <strong>B</strong></a></li>')

        expect(output).to include('<del aria-label="removed content">')
        expect(output).to include('<ins aria-label="added content">')
      end

      it "diffs a removed link against the matching line" do
        before_html = <<~HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link A</a></li>
                <li><a href="https://b.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        after_html = <<~HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://b.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        output = Nokodiff.diff(before_html, after_html)

        expect(output).to include('<li><a href="https://a.example.com">Link <strong>A</strong></a></li>')
        expect(output).to include('<li><a href="https://b.example.com"><strong>Link B</strong></a></li>')
        expect(output).to include('<li><a href="https://b.example.com">Link <strong>B</strong></a></li>')
      end
    end

    context "<strong> tagging" do
      describe "multiple consecutive added characters" do
        it "should merge the strong tags" do
          before_html = "<p> a </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include('<ins aria-label="added content"><p> a <strong>b c</strong></p></ins>')
        end
      end

      describe "multiple non consecutive added characters" do
        it "should not merge the strong tags" do
          before_html = "<p> b </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include('<ins aria-label="added content"><p> <strong>a </strong>b <strong>c</strong></p></ins>')
        end
      end
    end

    context "whitespace management" do
      describe "newline characters" do
        it "should not strong tag newline characters" do
          before_html = <<~HTML
            <div>
                <div>
                  <dl>
                  </dl>
                </div>
            </div>
          HTML

          after_html = <<~HTML
            <div>
                <div>
                  <p>Main</p>
                  <dl>
                  </dl>
                </div>
            </div>
          HTML

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include("<p><strong>Main</strong></p>")
          expect(result).not_to include("<dl><strong> </strong></dl>")
        end
      end
    end

    context "complex content" do
      let(:before_html) do
        File.read(
          File.expand_path("../spec/fixtures/html/complex_before_with_description.html", __dir__),
        )
      end

      let(:after_html) do
        File.read(
          File.expand_path("../spec/fixtures/html/complex_after_with_description.html", __dir__),
        )
      end

      let(:diff) do
        File.read(
          File.expand_path("../spec/fixtures/html/complex_diff_with_description.html", __dir__),
        )
      end

      it "highlights the right bit of output" do
        output = Nokodiff.diff(before_html, after_html)

        expect(output).to eq(diff)
      end
    end
  end
end
