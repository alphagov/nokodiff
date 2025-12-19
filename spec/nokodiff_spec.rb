# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
  end

  describe "#to_html" do
    context "when flat text" do
      describe "is unchanged" do
        let(:before_html) { "<p>Title: example</p>" }
        let(:after_html) { "<p>Title: example</p>" }

        it "returns the comparison of the unchanged HTML text" do
          output = Nokodiff.diff(before_html, after_html)

          expect(output).not_to include('<div class="diff">')
          expect(output).to include("Title: example")

          expect(output).not_to include('<del aria-label="removed content">')
          expect(output).not_to include('<ins aria-label="added content">')
        end
      end

      describe "changes at the end of a sentence" do
        let(:before_html) { "<p>Title: example</p>" }
        let(:after_html) { "<p>Title: new text</p>" }

        it "returns the comparison of the changed HTML text" do
          output = Nokodiff.diff(before_html, after_html)

          expect(output).to include('<div class="diff">')
          expect(output).to include('<del aria-label="removed content"><p>Title: e<strong>xampl</strong>e</p></del>')
          expect(output).to include('<ins aria-label="added content"><p>Title: <strong>n</strong>e<strong>w t</strong>e<strong>xt</strong></p></ins>')

          expect(output).to include('<del aria-label="removed content">')
          expect(output).to include('<ins aria-label="added content">')
        end
      end

      describe "changes in the middle of a sentence" do
        let(:before_html) { "<p>Monday to Friday, 9am to midday and 2pm to 4:30pm (closed on bank holidays)</p>" }
        let(:after_html) { "<p>Monday to Friday, 9am to midday (closed on bank holidays)</p>" }

        it "returns the comparison of the changed HTML text" do
          output = Nokodiff.diff(before_html, after_html)

          expect(output).to include('<div class="diff">')
          expect(output).to include('<del aria-label="removed content"><p>Monday to Friday, 9am to midday <strong>and 2pm to 4:30pm </strong>(closed on bank holidays)</p></del>')
          expect(output).to include('<ins aria-label="added content"><p>Monday to Friday, 9am to midday (closed on bank holidays)</p></ins>')

          expect(output).to include('<del aria-label="removed content">')
          expect(output).to include('<ins aria-label="added content">')
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

        expect(output).to include('<del aria-label="removed content">')
        expect(output).to include('<ins aria-label="added content">')
      end
    end
  end
end
