RSpec.describe "complex diff" do
  describe "#call" do
    context "added nodes" do
      before_html = <<~HTML
        <p>
            Test paragraph 1
        </p>
      HTML

      after_html = <<~HTML
        <p>
            Pre first paragraph
        </p>
        <p>
            Test paragraph 1
        </p>
      HTML

      it "counts the added node as the only new one" do
        output = Nokodiff.diff(before_html, after_html)

        puts output

        expect(output.squish).to include("<p> Test paragraph 1 </p>")
        expect(output.squish).to include('<div class="diff"> <ins aria-label="added content"><p> Pre first paragraph </p></ins> </div>')
        expect(output.squish).not_to include("<strong> Test paragraph 1 </strong>")
      end
    end
  end
end
