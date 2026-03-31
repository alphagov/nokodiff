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

    context "when a node is added inside a parent node" do
      let(:before_html) do
        <<~HTML
          <div class = "top-level">
              <p>Test paragraph 1</p>
          </div>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <div class = "top-level">
            <p>Pre first paragraph</p>
            <p>Test paragraph 1</p>
          </div>
        HTML
      end

      it "correctly wraps the new node in an ins tag as a sub element of the parent" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", class: "top-level") do
          with_tag("p", text: "Test paragraph 1")
          with_tag("div", class: "diff") do
            with_tag("ins", with: { "aria-label" => "added content" }) do
              with_tag("p", text: "Pre first paragraph")
            end
          end
        end
      end
    end

    context "when a node is removed inside a parent node" do
      let(:before_html) do
        <<~HTML
          <div class = "top-level">
              <p>Test paragraph 1</p>
              <p>Test paragraph to be deleted</p>
          </div>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <div class = "top-level">
            <p>Test paragraph 1</p>
          </div>
        HTML
      end

      it "correctly wraps the removed node in a del tag as a sub element of the parent" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", class: "top-level") do
          with_tag("p", text: "Test paragraph 1")
          with_tag("div", class: "diff") do
            with_tag("del", with: { "aria-label" => "removed content" }) do
              with_tag("p", text: "Test paragraph to be deleted")
            end
          end
        end
      end
    end

    context "when multiple nodes are changed within a list" do
      let(:before_html) do
        <<~HTML
          <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
          </ul>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <ul>
            <li>Item One</li>
            <li>Item 1.5</li>
            <li>Item 2</li>
          </ul>
        HTML
      end

      it "correctly highlights the added, changed and removed nodes in a list" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("ul") do
          with_tag("div", class: "diff") do
            with_tag("del", with: { "aria-label" => "removed content" }, text: "Item 1")
            with_tag("ins", with: { "aria-label" => "added content" }, text: "Item One")
          end
          with_tag("ins", with: { "aria-label" => "added content" }, text: "Item 1.5")
          with_tag("del", with: { "aria-label" => "removed content" }, text: "Item 3")
        end
      end
    end

    context "when a node is inserted within a structure multiple node layers deep" do
      let(:before_html) do
        <<~HTML
          <div class = "level-1">
            <div class = "level-2">
              <div class = "level-3">
                <p>Hello World</p>
                <div class = "level-4">
                 <p>Subclass text</p>
                </div>
              </div>
            </div>
          </div>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <div class = "level-1">
            <div class = "level-2">
              <div class = "level-3">
                <p>Hello World</p>
                <p>Goodbye World</p>
                    <div class = "level-4">
                        <p>Subclass text</p>
                    </div>
              </div>
            </div>
          </div>
        HTML
      end

      it "correctly highlights the added node, while retaining the surrounding node structure" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", class: "level-1") do
          with_tag("div", class: "level-2") do
            with_tag("div", class: "level-3") do
              with_tag("p", text: "Hello World")
              with_tag("div", class: "diff") do
                with_tag("ins", with: { "aria-label" => "added content" }) do
                  with_tag("p", text: "Goodbye World")
                end
              end
              with_tag("div", class: "level-4") do
                with_tag("p", text: "Subclass text")
              end
            end
          end
        end
      end
    end

    context "when multiple nodes are changed in different branches of a branching node structure" do
      let(:before_html) do
        <<~HTML
          <div class = "level-1">
            <div class = "level-2a">
              <p>Retain me</p>
              <p>Delete me</p>
            </div>
            <div class = "level-2b">
              <p>Retain me</p>
            </div>
            <div class = "level-2c">
              <p>Retain me</p>
            </div>
          </div>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <div class = "level-1">
            <div class = "level-2a">
              <p>Retain me</p>
            </div>
            <div class = "level-2b">
              <p>Retain me</p>
            </div>
            <div class = "level-2c">
              <p>Retain me</p>
              <p>New line</p>
            </div>
          </div>
        HTML
      end

      it "correctly highlights the changed nodes, while retaining the surrounding node structure" do
        result = Nokodiff.diff(before_html, after_html)

        expect(result).to have_tag("div", class: "level-1") do
          with_tag("div", class: "level-2a") do
            with_tag("p", text: "Retain me")
            with_tag("div", class: "diff") do
              with_tag("del", with: { "aria-label" => "removed content" }) do
                with_tag("p", text: "Delete me")
              end
            end
          end
          with_tag("div", class: "level-2b") do
            with_tag("p", text: "Retain me")
          end
          with_tag("div", class: "level-2c") do
            with_tag("p", text: "Retain me")
            with_tag("div", class: "diff") do
              with_tag("ins", with: { "aria-label" => "added content" }) do
                with_tag("p", text: "New line")
              end
            end
          end
        end
      end
    end
  end
end
