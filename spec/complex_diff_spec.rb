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

      let(:expected_html) do
        <<~HTML
          <p class="diff ins">
            <span class="visually-hidden"> Added content </span>Pre first paragraph
          </p>

          <p>Test paragraph 1</p>
        HTML
      end

      it "gives the new node the ins class and accessible callout while keeping the existing node unchanged" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
          <p>Test paragraph 1</p>
          <p class="diff del">
            <span class="visually-hidden"> Removed content </span>Post first paragraph
          </p>
        HTML
      end

      it "gives the removed node the del class and accessible callout" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end

    context "when content is changed inside a div" do
      let(:before_html) do
        <<~HTML
          <div>
            test content
          </div>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <div>
            Test content
          </div>
        HTML
      end

      let(:expected_html) do
        <<~HTML
          <div>
              <span class="diff del">
                <span class="visually-hidden">Removed content </span>

                <span class="diff-marker">t</span>est content

              </span>
              <span class="diff ins">
                <span class="visually-hidden">Added content </span>

                <span class="diff-marker">T</span>est content

              </span>
            </div>
        HTML
      end

      it "highlights the changes using a span, and accessible callout" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
          <div class="top-level">
              <p class="diff ins">
                <span class="visually-hidden"> Added content </span>Pre first paragraph
              </p>

              <p>Test paragraph 1</p>
            </div>
        HTML
      end

      it "correctly gives the new node the ins class and accessible callout as a sub element of the parent" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
          <div class="top-level">
            <p>Test paragraph 1</p>

             <p class="diff del">
                <span class="visually-hidden"> Removed content </span>Test paragraph to be deleted
             </p>
          </div>
        HTML
      end

      it "correctly gives the removed node the del class and accessible callout as a sub element of the parent" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
           <ul>
              <li class="diff del">
                 <span class="visually-hidden"> Removed content </span>Item <span class="diff-marker">1</span>
              </li>
              <li class="diff ins">
                 <span class="visually-hidden"> Added content </span>Item <span class="diff-marker">One</span>
              </li>

              <li class="diff ins">
                 <span class="visually-hidden"> Added content </span>Item 1.5
              </li>

              <li>Item 2</li>

              <li class="diff del">
                 <span class="visually-hidden"> Removed content </span>Item 3
              </li>
          </ul>
        HTML
      end

      it "correctly highlights the added, changed and removed nodes in a list with the divs inside each list item" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end

      context "when list items contain nested elements" do
        let(:before_html) do
          <<~HTML
            <ul>
              <li>Item <span>1</span></li>
              <li>Item 2</li>
              <li>Item 3</li>
            </ul>
          HTML
        end

        let(:after_html) do
          <<~HTML
            <ul>
              <li>Item <span>one</span></li>
              <li>Item 2</li>
              <li>Item 3</li>
            </ul>
          HTML
        end

        let(:expected_html) do
          <<~HTML
             <ul>
               <li class="diff del">
                   <span class="visually-hidden"> Removed content </span>Item <span><span class="diff-marker">1</span></span>
                </li>
                <li class="diff ins">
                   <span class="visually-hidden"> Added content </span>Item <span><span class="diff-marker">one</span></span>
                </li>

                <li>Item 2</li>

                <li>Item 3</li>
            </ul>
          HTML
        end

        it "correctly highlights the added, changed and removed nodes in a list with the divs inside each list item and the spans included" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
           <div class="level-1"><div class="level-2"><div class="level-3">
              <p>Hello World</p>

              <p class="diff ins">
                 <span class="visually-hidden"> Added content </span>Goodbye World
              </p>

              <div class="level-4"><p>Subclass text</p></div>
          </div></div></div>
        HTML
      end

      it "correctly highlights the added node, while retaining the surrounding node structure" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
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

      let(:expected_html) do
        <<~HTML
          <div class="level-1">
             <div class="level-2a">
             <p>Retain me</p>

             <p class="diff del">
                <span class="visually-hidden"> Removed content </span>Delete me
             </p>
             </div>
             <div class="level-2b"><p>Retain me</p></div>

             <div class="level-2c">
               <p>Retain me</p>
               <p class="diff ins">
                  <span class="visually-hidden"> Added content </span>New line
               </p>
             </div>
          </div>
        HTML
      end

      it "correctly highlights the changed nodes, while retaining the surrounding node structure" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end

    describe "when a node is changed within a heading" do
      (1..6).each do |level|
        context "when changes are made within a h#{level}" do
          let(:before_html) do
            <<~HTML
              <h#{level}>Test heading</h#{level}>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <h#{level}>Testing heading</h#{level}>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <h#{level} class="diff del">
                 <span class="visually-hidden"> Removed content </span>Test heading
              </h#{level}>
              <h#{level} class="diff ins">
                 <span class="visually-hidden"> Added content </span>Test<span class="diff-marker">ing</span> heading
              </h#{level}>
            HTML
          end

          it "highlights the entire heading as a change" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end
        end

        context "when changes are made within a h#{level} with a nested element" do
          let(:before_html) do
            <<~HTML
              <h#{level}><span>Test</span> heading</h#{level}>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <h#{level}><span>Testing</span> heading</h#{level}>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <h#{level} class="diff del">
                <span class="visually-hidden"> Removed content </span><span>Test</span> heading
              </h#{level}>
              <h#{level} class="diff ins">
                <span class="visually-hidden"> Added content </span><span>Test<span class="diff-marker">ing</span></span> heading
              </h#{level}>
            HTML
          end

          it "highlights the entire heading as a change" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end
        end
      end
    end

    context "when text nodes are added with line breaks" do
      let(:before_html) do
        <<~HTML
          <p>123 Real Street<br>
          Springfield<br>
          England</p>
        HTML
      end

      let(:after_html) do
        <<~HTML
          <p>123 Real Street<br>
          Springfield<br>
          England<br>
          TEST 123</p>
        HTML
      end

      let(:expected_html) do
        <<~HTML
           <p class="diff del">
               <span class="visually-hidden"> Removed content </span>123 Real Street<br>
            Springfield<br>
            England
            </p>
            <p class="diff ins">
               <span class="visually-hidden"> Added content </span>123 Real Street<br>
            Springfield<br>
            England<br><span class="diff-marker">
            TEST 123</span>
          </p>
        HTML
      end

      it "gives the changed node the ins class and accessible callout with the added text node highlighted" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end
  end
end
