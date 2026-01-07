# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
  end

  describe "#to_html" do
    context "when flat text nodes" do
      describe "are unchanged" do
        it "returns unchanged html" do
          html = "<p>Hello world!</p>"

          result = Nokodiff.diff(html, html)

          expect(result).to include("<p>Hello world!</p>")
          expect(result).not_to include('<div class="diff">')
          expect(result).not_to include("<del>")
          expect(result).not_to include("<ins>")
        end
      end

      describe "are changed" do
        it "wraps changed blocks in del and ins tags" do
          before_html = "<p>Hello world!</p>"
          after_html = "<p>Goodbye world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include("<del><p><strong>Hell</strong>o world!</p></del>")
          expect(result).to include("<ins><p><strong>G</strong>o<strong>odbye</strong> world!</p></ins>")
        end
      end

      describe "are deleted" do
        it "handles completely deleting content" do
          before_html = "<p>Hello world!</p>"
          after_html = ""

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include("<del><p>Hello world!</p></del>")
          expect(result).not_to include("<ins>")
        end
      end

      describe "are added" do
        it "handles adding entirely new content" do
          before_html = ""
          after_html = "<p>Hello world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).not_to include("<del>")
          expect(result).to include("<ins><p>Hello world!</p></ins>")
        end
      end
    end
    context "links" do
      it "diffs changed link text" do
        before_html = <<-HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link A</a></li>
              </ul>
          </div>
        HTML

        after_html = <<-HTML
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

        expect(output).to include("<del>")
        expect(output).to include("<ins>")
      end
    end

    context "<strong> tagging" do
      describe "multiple consecutive added characters" do
        it "should merge the strong tags" do
          before_html = "<p> a </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include("<ins><p> a <strong>b c</strong></p></ins>")
        end
      end

      describe "multiple non consecutive added characters" do
        it "should not merge the strong tags" do
          before_html = "<p> b </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to include('<div class="diff">')
          expect(result).to include("<ins><p> <strong>a </strong>b <strong>c</strong></p></ins>")
        end
      end
    end
  end
end
