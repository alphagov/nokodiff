RSpec.describe "complex diff" do
  describe "#call" do
    context "when nodes are added" do
      let(:before_html) do
        <<~HTML
          <p>Test paragraph 1</p>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <p>Pre first paragraph</p>
          <p>Test paragraph 1</p>
        HTML
      end

      it "wraps the new node in an ins tag while keeping the existing node unchanged" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("p", text: "Test paragraph 1")

        expect(result).to have_tag("div", class: "diff") do
          with_tag("ins", with: { "aria-label" => "added content" }) do
            with_tag("p", text: "Pre first paragraph")
          end
        end
      end
    end

    context "when nodes are deleted" do
      let(:before_html) do
        <<~HTML
          <p>Test paragraph 1</p>
          <p>Post first paragraph</p>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <p>Test paragraph 1</p>
        HTML
      end

      it "wraps the removed node in a del tag" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("p", text: "Test paragraph 1")

        expect(result).to have_tag("div", class: "diff") do
          with_tag("del", with: { "aria-label" => "removed content" }) do
            with_tag("p", text: "Post first paragraph")
          end
        end
      end
    end
  end
end
