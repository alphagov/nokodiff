# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
  end

  describe ".safe_html" do
    let(:fake_html) { double("fake html") }
    let(:result) { described_class.safe_html(fake_html) }

    before { stub_const("Differ", Class.new) }

    it "returns html_safe when html responds to html_safe" do
      allow(fake_html).to receive(:respond_to?).with(:html_safe).and_return(true)
      allow(fake_html).to receive(:html_safe).and_return("html_safe version")

      expect(result).to eq("html_safe version")
    end

    it "returns the original object when html_safe is not available" do
      allow(fake_html).to receive(:respond_to?).with(:html_safe).and_return(false)

      expect(result).to eq(fake_html)
    end
  end

  describe "#to_html" do
    context "when flat text nodes" do
      describe "are unchanged" do
        let(:html) { "<p>Hello world!</p>" }

        it "returns unchanged html" do
          result = Nokodiff.diff(html, html)

          expect(result).to eq(html)
        end
      end

      describe "are changed" do
        let(:before_html) { "<p>Hello world!</p>" }
        let(:after_html) { "<p>Goodbye world!</p>" }
        let(:expected_html) do
          <<~HTML
            <p class="diff del">
              <span class="visually-hidden"> Removed content </span><span class="diff-marker">Hell</span>o world!
            </p>
            <p class="diff ins">
              <span class="visually-hidden"> Added content </span><span class="diff-marker">G</span>o<span class="diff-marker">odbye</span> world!
            </p>
          HTML
        end

        it "wraps changed blocks in del and ins classes and marker text" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      describe "are deleted" do
        let(:before_html) { "<p>Hello world!</p>" }
        let(:after_html) { "" }
        let(:expected_html) do
          <<~HTML
            <p class="diff del">
              <span class="visually-hidden"> Removed content </span>Hello world!
            </p>
          HTML
        end

        it "handles completely deleting content" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      describe "are added" do
        let(:before_html) { "" }
        let(:after_html) { "<p>Hello world!</p>" }
        let(:expected_html) do
          <<~HTML
            <p class="diff ins">
              <span class="visually-hidden"> Added content </span>Hello world!
            </p>
          HTML
        end

        it "handles adding entirely new content" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end
    end

    context "when links" do
      describe "are changed" do
        let(:before_html) do
          <<~HTML
            <div>
              <p><strong>Example links:</strong></p>
                <ul>
                  <li><a href="https://a.example.com">Link A</a></li>
                </ul>
            </div>
          HTML
        end

        let(:after_html) do
          <<~HTML
            <div>
              <p><strong>Example links:</strong></p>
                <ul>
                  <li><a href="https://a.example.com">Link B</a></li>
                </ul>
            </div>
          HTML
        end

        let(:expected_html) do
          <<~HTML
              <div>
                <p><strong>Example links:</strong></p>

                <ul>
                  <li class="diff del">
                    <span class="visually-hidden"> Removed content </span><a href="https://a.example.com">Link <span class="diff-marker">A</span></a>
                  </li>
                  <li class="diff ins">
                    <span class="visually-hidden"> Added content </span><a href="https://a.example.com">Link <span class="diff-marker">B</span></a>
                  </li>
                </ul>
            </div>
          HTML
        end

        it "diffs changed link text" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end
      describe "are removed" do
        let(:before_html) do
          <<~HTML
            <div>
              <p><strong>Example links:</strong></p>
                <ul>
                  <li><a href="https://a.example.com">Link A</a></li>
                  <li><a href="https://b.example.com">Link B</a></li>
                </ul>
            </div>
          HTML
        end

        let(:after_html) do
          <<~HTML
            <div>
              <p><strong>Example links:</strong></p>
                <ul>
                  <li><a href="https://b.example.com">Link B</a></li>
                </ul>
            </div>
          HTML
        end

        let(:expected_html) do
          <<~HTML
              <div>
                <p><strong>Example links:</strong></p>

                <ul>
                  <li class="diff del">
                    <span class="visually-hidden"> Removed content </span><a href="https://a.example.com">Link A</a>
                  </li>

                  <li><a href="https://b.example.com">Link B</a></li>
                </ul>
            </div>
          HTML
        end

        it "diffs a removed link against the matching line" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end
    end

    context "<span> tagging" do
      describe "multiple consecutive added characters" do
        let(:before_html) { "<p> a</p>" }
        let(:after_html) { "<p> a b c</p>" }
        let(:expected_html) do
          <<~HTML
            <p class="diff del">
              <span class="visually-hidden"> Removed content </span> a
            </p>
            <p class="diff ins">
              <span class="visually-hidden"> Added content </span> a<span class="diff-marker"> b c</span>
            </p>
          HTML
        end

        it "should merge the span tags" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      describe "multiple non consecutive added characters" do
        let(:before_html) { "<p> b</p>" }
        let(:after_html) { "<p> a b c</p>" }
        let(:expected_html) do
          <<~HTML
            <p class="diff del">
              <span class="visually-hidden"> Removed content </span> b
            </p>
            <p class="diff ins">
              <span class="visually-hidden"> Added content </span> <span class="diff-marker">a </span>b<span class="diff-marker"> c</span>
            </p>
          HTML
        end

        it "should not merge the span tags" do
          result = Nokodiff.diff(before_html, after_html)
          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end
    end
  end

  context "when `data-diff-key` attributes are present" do
    context "when an element has been added" do
      let(:before_html) { load_fixture("complex/added/before") }
      let(:after_html) { load_fixture("complex/added/after") }
      let(:expected_html) { load_fixture("complex/added/diff") }

      it "adds a diff showing the added content" do
        result = Nokodiff.diff(before_html, after_html)
        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end

    context "when an element has been modified" do
      let(:before_html) { load_fixture("complex/modified/before") }
      let(:after_html) { load_fixture("complex/modified/after") }
      let(:expected_html) { load_fixture("complex/modified/diff") }

      it "adds a diff showing the content modifications" do
        result = Nokodiff.diff(before_html, after_html)
        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end
  end
end
