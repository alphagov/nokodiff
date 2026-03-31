# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
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

          expect(result).to have_tag("p", text: "Hello world!")
          expect(result).not_to have_tag("div", with: { class: "diff" })
          expect(result).not_to have_tag("del", with: { "aria-label" => "removed content" })
          expect(result).not_to have_tag("ins", with: { "aria-label" => "added content" })
        end
      end

      describe "are changed" do
        it "wraps changed blocks in del and ins tags" do
          before_html = "<p>Hello world!</p>"
          after_html = "<p>Goodbye world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to have_tag("div", with: { class: "diff" })
          expect(result).to have_tag("del", with: { "aria-label" => "removed content" }) do
            with_tag("p") do
              with_tag("span", class: "diff-marker", text: "Hell")
            end
          end
          expect(result).to have_tag("ins", with: { "aria-label" => "added content" }) do
            with_tag("p") do
              with_tag("span", class: "diff-marker", text: "G")
              with_tag("span", class: "diff-marker", text: "odbye")
            end
          end
        end
      end

      describe "are deleted" do
        it "handles completely deleting content" do
          before_html = "<p>Hello world!</p>"
          after_html = ""

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to have_tag("div", with: { class: "diff" })
          expect(result).to have_tag("del", with: { "aria-label" => "removed content" }) do
            with_tag("p", text: "Hello world!")
          end
          expect(result).not_to have_tag("ins", with: { "aria-label" => "added content" })
        end
      end

      describe "are added" do
        it "handles adding entirely new content" do
          before_html = ""
          after_html = "<p>Hello world!</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to have_tag("div", with: { class: "diff" })
          expect(result).not_to have_tag("del", with: { "aria-label" => "removed content" })
          expect(result).to have_tag("ins", with: { "aria-label" => "added content" }) do
            with_tag("p", text: "Hello world!")
          end
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

        expect(output).to have_tag("a", with: { href: "https://a.example.com" }) do
          with_tag("span", class: "diff-marker", text: "A")
        end
        expect(output).to have_tag("a", with: { href: "https://a.example.com" }) do
          with_tag("span", class: "diff-marker", text: "B")
        end
        expect(output).to have_tag("del", with: { "aria-label" => "removed content" })
        expect(output).to have_tag("ins", with: { "aria-label" => "added content" })
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

        expect(output).to have_tag("del", with: { "aria-label" => "removed content" }) do
          with_tag("a", with: { href: "https://a.example.com" }, text: "Link A")
        end
        expect(output).to have_tag("a", with: { href: "https://b.example.com" }, text: "Link B")
      end
    end

    context "<span> tagging" do
      describe "multiple consecutive added characters" do
        it "should merge the span tags" do
          before_html = "<p> a </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to have_tag("div", with: { class: "diff" })
          expect(result).to have_tag("ins", with: { "aria-label" => "added content" }) do
            with_tag("p") do
              with_tag("span", class: "diff-marker", text: "b c")
            end
          end
        end
      end

      describe "multiple non consecutive added characters" do
        it "should not merge the span tags" do
          before_html = "<p> b </p>"
          after_html = "<p> a b c</p>"

          result = Nokodiff.diff(before_html, after_html)

          expect(result).to have_tag("div", with: { class: "diff" })
          expect(result).to have_tag("ins", with: { "aria-label" => "added content" }) do
            with_tag("p") do
              with_tag("span", class: "diff-marker", text: "a ")
              with_tag("span", class: "diff-marker", text: "c")
            end
          end
        end
      end
    end
  end

  context "when `data-diff-key` attributes are present" do
    context "when an element has been added" do
      let(:before_html) { load_fixture("complex/added/before") }
      let(:after_html) { load_fixture("complex/added/after") }

      it "adds a diff showing the added content" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", with: { "data-diff-key" => "description" }) do
          with_tag("div", class: "diff") do
            with_tag("ins", with: { "aria-label" => "added content" }) do
              with_text("Main contact info")
            end
            without_tag("del")
          end
        end

        expect(result).to have_tag("div", with: { "data-diff-key" => "telephone-1" }) do
          without_tag("ins")
          without_tag("del")
        end
      end
    end

    context "when an element has been modified" do
      let(:before_html) { load_fixture("complex/modified/before") }
      let(:after_html) { load_fixture("complex/modified/after") }

      it "adds a diff showing the content modifications" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", with: { "data-diff-key" => "telephone-1" }) do
          with_tag("div", class: "diff") do
            with_tag("span", class: "tel", text: "0300 123 123") do
              with_tag("del", with: { "aria-label" => "removed content" })
            end
            with_tag("span", class: "tel", text: "0300 345 345") do
              with_tag("ins", with: { "aria-label" => "added content" })
            end
          end
        end
      end
    end
  end
end
