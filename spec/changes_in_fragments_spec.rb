RSpec.describe ChangesInFragments do
  describe "#call" do
    context "when given a single addition" do
      let(:diff) do
        old_chars = %w[a]
        new_chars = %w[a b]

        Diff::LCS.sdiff(old_chars, new_chars)
      end

      it "emphasises the addition in the 'new' fragment" do
        _, new_fragment = ChangesInFragments.new(diff).call
        expect(new_fragment.to_s).to eq("a<strong>b</strong>")
      end

      it "leaves the pre-existing element unemphasised in the 'old' fragment" do
        old_fragment, _ = ChangesInFragments.new(diff).call
        expect(old_fragment.to_s).to eq("a")
      end
    end
  end
end