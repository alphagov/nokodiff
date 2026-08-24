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
          <p>
              <span class="diff ins">
                <span class="visually-hidden">Added content </span>
                Pre first paragraph
              </span>
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
          <p>
              <span class="diff del">
                <span class="visually-hidden">Removed content </span>
                Post first paragraph
              </span>
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
              <p>
                <span class="diff ins">
                  <span class="visually-hidden">Added content </span>
                  Pre first paragraph
                </span>
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

             <p>
              <span class="diff del">
                <span class="visually-hidden">Removed content </span>
                Test paragraph to be deleted
              </span>
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
              <li>
              <span class="diff del">
                 <span class="visually-hidden">Removed content </span>
                 Item <span class="diff-marker">1</span>
               </span>
              </li>
              <li>
              <span class="diff ins">
                 <span class="visually-hidden">Added content </span>
                 Item <span class="diff-marker">One</span>
               </span>
              </li>

              <li>
              <span class="diff ins">
                 <span class="visually-hidden">Added content </span>
                 Item 1.5
               </span>
              </li>

              <li>Item 2</li>

              <li>
              <span class="diff del">
                 <span class="visually-hidden">Removed content </span>
                 Item 3
               </span>
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
               <li>
                    <span class="diff del">
                       <span class="visually-hidden">Removed content </span>
                       Item <span><span class="diff-marker">1</span></span>
                    </span>
                </li>
                <li>
                    <span class="diff ins">
                       <span class="visually-hidden">Added content </span>
                       Item <span><span class="diff-marker">one</span></span>
                   </span>
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

              <p>
                <span class="diff ins">
                   <span class="visually-hidden">Added content </span>
                   Goodbye World
                 </span>
              </p>
          #{'    '}
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

               <p>
                    <span class="diff del">
                      <span class="visually-hidden">Removed content </span>
                      Delete me
                    </span>
               </p>
             </div>
             <div class="level-2b"><p>Retain me</p></div>

             <div class="level-2c">
               <p>Retain me</p>
               <p>
                 <span class="diff ins">
                   <span class="visually-hidden">Added content </span>
                     New line
                 </span>
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
              <h#{level}>
                <span class="diff del">
                   <span class="visually-hidden">Removed content </span>
                   Test heading
                </span>
              </h#{level}>
              <h#{level}>
                <span class="diff ins">
                  <span class="visually-hidden">Added content </span>
                  Test<span class="diff-marker">ing</span> heading
                </span>
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
              <h#{level}>
                <span class="diff del">
                  <span class="visually-hidden">Removed content </span>
                  <span>Test</span> heading
                </span>
              </h#{level}>
              <h#{level}>
                <span class="diff ins">
                  <span class="visually-hidden">Added content </span>
                  <span>Test<span class="diff-marker">ing</span></span> heading
                </span>
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
          <p>
            <span class="diff del">
              <span class="visually-hidden">Removed content </span>
              123 Real Street<br>
              Springfield<br>
              England
            </span>
          </p>
          <p>
            <span class="diff ins">
               <span class="visually-hidden">Added content </span>
               123 Real Street<br>
               Springfield<br>
               England<br><span class="diff-marker">
               TEST 123</span>
           </span>
          </p>
        HTML
      end

      it "gives the changed node the ins class and accessible callout with the added text node highlighted" do
        result = Nokodiff.diff(before_html, after_html)

        expect(normalise_html(result)).to eq(normalise_html(expected_html))
      end
    end

    context "when a sub-element of a" do
      # This is split between Paragraph and Table as when this issuse was first investigated, Table was affected slightly differently and caused an exception rather than just a malformed diff
      context "paragraph" do
        context "is added" do
          let(:before_html) do
            <<~HTML
              <p>Unbolded other</p>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <p><b>Bolded</b> other</p>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <p>
                <span class="diff del">
                  <span class="visually-hidden">Removed content </span>
                  <span class="diff-marker">Unbolded other</span>
                </span>
              </p>
              <p>
                <span class="diff ins">
                  <span class="visually-hidden">Added content </span>
                  <span class="diff-marker"><b>Bolded</b> other</span>
                </span>
              </p>
            HTML
          end

          it "is not able to correctly highlight the diff, and the sub-element tag is lost" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end

          it "does not crash" do
            expect { Nokodiff.diff(before_html, after_html) }.not_to raise_error
          end
        end

        context "is removed" do
          let(:before_html) do
            <<~HTML
              <p><b>Bolded</b> other</p>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <p>Unbolded other</p>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <p>
                <span class="diff del">
                  <span class="visually-hidden">Removed content </span>
                  <span class="diff-marker"><b>Bolded</b> other</span>
                </span>
              </p>
              <p>
              <span class="diff ins">
                  <span class="visually-hidden">Added content </span>
                  <span class="diff-marker">Unbolded other</span>
                </span>
              </p>
            HTML
          end

          it "is not able to correctly highlight the diff, and the sub-element tag is lost" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end

          it "does not crash" do
            expect { Nokodiff.diff(before_html, after_html) }.not_to raise_error
          end
        end
      end

      context "table cell" do
        context "is added" do
          let(:before_html) do
            <<~HTML
              <table>
                <tbody>
                    <tr>
                        <td>Unbolded other</td>
                    </tr>
                </tbody>
              </table>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <table>
                <tbody>
                    <tr>
                        <td><b>Bolded</b> other</td>
                    </tr>
                </tbody>
              </table>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <table><tbody>
                    <tr class="diff del">
                        <td>
                            <span class="visually-hidden">Removed row </span><span class="diff-marker">Unbolded other</span>
                            </td>
                    </tr>
                    <tr class="diff ins">
                        <td>
                            <span class="visually-hidden">Added  row </span><span class="diff-marker"><b>Bolded</b> other</span>
                        </td>
                    </tr>
              </tbody></table>
            HTML
          end

          it "is not able to correctly highlight the diff, and the sub-element tag is lost" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end

          it "does not crash" do
            expect { Nokodiff.diff(before_html, after_html) }.not_to raise_error
          end
        end

        context "is removed" do
          let(:before_html) do
            <<~HTML
              <table>
                <tbody>
                    <tr>
                        <td><b>Bolded</b> other</td>
                    </tr>
                </tbody>
              </table>
            HTML
          end

          let(:after_html) do
            <<~HTML
              <table>
                <tbody>
                    <tr>
                        <td>Unbolded other</td>
                    </tr>
                </tbody>
              </table>
            HTML
          end

          let(:expected_html) do
            <<~HTML
              <table><tbody>
                    <tr class="diff del">
                        <td>
                        <span class="visually-hidden">Removed row </span><span class="diff-marker"><b>Bolded</b> other</span>
                        </td>
                    </tr>
                    <tr class="diff ins">
                        <td>
                        <span class="visually-hidden">Added  row </span><span class="diff-marker">Unbolded other</span>
                        </td>
                    </tr>
              </tbody></table>
            HTML
          end

          it "is not able to correctly highlight the diff, and the sub-element tag is lost" do
            result = Nokodiff.diff(before_html, after_html)

            expect(normalise_html(result)).to eq(normalise_html(expected_html))
          end

          it "does not crash" do
            expect { Nokodiff.diff(before_html, after_html) }.not_to raise_error
          end
        end
      end
    end

    context "when a node is changed within a table" do
      let(:before_html) do
        <<~HTML
          <table>
            <thead><tr>
                <th scope="col">col1</th>
                <th scope="col">col2</th>
            </tr></thead>
            <tbody><tr>
                <td>r1c1</td>
                <td>r1c2</td>
            </tr></tbody>
          </table>
        HTML
      end

      context "when an entire table row is added to a table" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead>
                <tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
                </tr>
                <tr>
                  <td>r2c1</td>
                  <td>r2c2</td>
                </tr>
              </tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead><tr>
                <th scope="col">col1</th>
                <th scope="col">col2</th>
              </tr></thead>

              <tbody>
                <tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
                </tr>
                <tr class="diff ins">
                  <td>
                      <span class="visually-hidden">Added  row </span>r2c1</td>
                  <td>r2c2</td>
                </tr>
              </tbody>
            </table>
          HTML
        end

        it "correctly highlights the change, using the Added Row accessible callout" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when an entire table row is removed from a table" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead>
                <tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
                </tr>
              </thead>
              <tbody>
              </tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead><tr>
                <th scope="col">col1</th>
                <th scope="col">col2</th>
              </tr></thead>

              <tbody>
                <tr class="diff del">
                  <td>
                      <span class="visually-hidden">Removed row </span>r1c1</td>
                  <td>r1c2</td>
                </tr>
              </tbody>
            </table>
          HTML
        end

        it "correctly highlights the change, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a cell is removed from a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>

              <tbody>
                  <tr class="diff del">
                    <td>
                        <span class="visually-hidden">Removed row </span>r1c1</td>
                    <td><span class="diff-marker">r1c2</span></td>
              </tr>
              <tr class="diff ins">
                  <td>
                    <span class="visually-hidden">Added  row </span>r1c1</td>
              </tr>
              </tbody>
            </table>
          HTML
        end

        it "correctly highlights the removed cell, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a cell is added to a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
                  <td>r1c3</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>

              <tbody>
                  <tr class="diff del">
                    <td>
                        <span class="visually-hidden">Removed row </span>r1c1</td>
                    <td>r1c2</td>
              </tr>
              <tr class="diff ins">
                  <td>
                    <span class="visually-hidden">Added  row </span>r1c1</td>
                  <td>r1c2</td>
                  <td><span class="diff-marker">r1c3</span></td>
              </tr>
              </tbody>
            </table>
          HTML
        end

        it "correctly highlights the added cell, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a cell is modified within a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>Changed</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
              </tr></thead>

              <tbody>
                  <tr class="diff del">
                    <td>
                    <span class="visually-hidden">Removed row </span>r1c1</td>
                  <td><span class="diff-marker">r1c2</span></td>
              </tr>
              <tr class="diff ins">
                  <td>
                    <span class="visually-hidden">Added  row </span>r1c1</td>
                  <td><span class="diff-marker">Changed</span></td>
              </tr>
              </tbody>
            </table>
          HTML
        end

        it "correctly highlights the changed cell, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a heading is removed from a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead>
                <tr class="diff del">
                  <th scope="col">
                    <span class="visually-hidden">Removed row </span>col1</th>
                  <th scope="col"><span class="diff-marker">col2</span></th>
                </tr>
                <tr class="diff ins">
                    <th scope="col">
                      <span class="visually-hidden">Added  row </span>col1</th>
                </tr>
              </thead>
              <tbody><tr>
                    <td>r1c1</td>
                    <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        it "correctly highlights the removed heading, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a heading is added to a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col2</th>
                  <th scope="col">col3</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead>
                <tr class="diff del">
                  <th scope="col">
                    <span class="visually-hidden">Removed row </span>col1</th>
                  <th scope="col">col2</th>
                </tr>
                <tr class="diff ins">
                    <th scope="col">
                      <span class="visually-hidden">Added  row </span>col1</th>
                    <th scope="col">col2</th>
                    <th scope="col"><span class="diff-marker">col3</span></th>
                </tr>
              </thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        it "correctly highlights the added heading, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end

      context "when a heading is modified within a table row" do
        let(:after_html) do
          <<~HTML
            <table>
              <thead><tr>
                  <th scope="col">col1</th>
                  <th scope="col">col two</th>
              </tr></thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        let(:expected_html) do
          <<~HTML
            <table>
              <thead>
                <tr class="diff del">
                  <th scope="col">
                    <span class="visually-hidden">Removed row </span>col1</th>
                  <th scope="col">col<span class="diff-marker">2</span>
                  </th>
                </tr>
                <tr class="diff ins">
                    <th scope="col">
                      <span class="visually-hidden">Added  row </span>col1</th>
                    <th scope="col">col<span class="diff-marker"> two</span>
                    </th>
                </tr>
              </thead>
              <tbody><tr>
                  <td>r1c1</td>
                  <td>r1c2</td>
              </tr></tbody>
            </table>
          HTML
        end

        it "correctly highlights the changed heading, with the row as the lowest level element" do
          result = Nokodiff.diff(before_html, after_html)

          expect(normalise_html(result)).to eq(normalise_html(expected_html))
        end
      end
    end
  end
end
