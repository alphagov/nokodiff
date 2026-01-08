RSpec.describe ChangesInFragments do
  describe "#call" do
    context "when nothing changes" do
      let(:diff) do
        before_chars = %w[a b]
        after_chars = %w[a b]

        Diff::LCS.sdiff(before_chars, after_chars)
      end

      it "nothing is emphasised in the 'old' fragment" do
        _, before_fragment = ChangesInFragments.new(diff).call
        expect(before_fragment.to_s).to eq("ab")
      end

      it "nothing is emphasised in the 'new' fragment" do
        after_fragment, = ChangesInFragments.new(diff).call
        expect(after_fragment.to_s).to eq("ab")
      end
    end

    context "when given a single addition" do
      let(:diff) do
        before_chars = %w[a]
        after_chars = %w[a b]

        Diff::LCS.sdiff(before_chars, after_chars)
      end

      it "emphasises the addition in the 'new' fragment" do
        _, after_fragment = ChangesInFragments.new(diff).call
        expect(after_fragment.to_s).to eq("a<strong>b</strong>")
      end

      it "leaves the pre-existing element unemphasised in the 'old' fragment" do
        before_fragment, = ChangesInFragments.new(diff).call
        expect(before_fragment.to_s).to eq("a")
      end
    end

    context "when given a multiple additions" do
      let(:diff) do
        before_chars = %w[a]
        after_chars = %w[a b c]

        Diff::LCS.sdiff(before_chars, after_chars)
      end

      it "emphasises each addition individually in the 'new' fragment" do
        _, after_fragment = ChangesInFragments.new(diff).call
        expect(after_fragment.to_s).to eq("a<strong>b</strong><strong>c</strong>")
      end

      it "leaves the pre-existing element unemphasised in the 'old' fragment" do
        before_fragment, = ChangesInFragments.new(diff).call
        expect(before_fragment.to_s).to eq("a")
      end
    end

    context "when given a single deletion" do
      let(:diff) do
        before_chars = %w[a b]
        after_chars = %w[a]

        Diff::LCS.sdiff(before_chars, after_chars)
      end

      it "leaves the pre-existing element unemphasised in the 'new' fragment" do
        _, after_fragment = ChangesInFragments.new(diff).call
        expect(after_fragment.to_s).to eq("a")
      end

      it "emphasises the deletion in the 'old' fragment" do
        before_fragment, = ChangesInFragments.new(diff).call
        expect(before_fragment.to_s).to eq("a<strong>b</strong>")
      end
    end

    context "when given a single change" do
      let(:diff) do
        before_chars = %w[a b]
        after_chars = %w[a c]

        Diff::LCS.sdiff(before_chars, after_chars)
      end

      it "emphasises the addition in the 'new' fragment" do
        _, after_fragment = ChangesInFragments.new(diff).call
        expect(after_fragment.to_s).to eq("a<strong>c</strong>")
      end

      it "emphasises the deletion in the 'old' fragment" do
        before_fragment, = ChangesInFragments.new(diff).call
        expect(before_fragment.to_s).to eq("a<strong>b</strong>")
      end
    end
  end
end
