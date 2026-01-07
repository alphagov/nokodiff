# frozen_string_literal: true

RSpec.describe Nokodiff do
  it "has a version number" do
    expect(Nokodiff::VERSION).not_to be nil
  end

  it "returns unchanged html when content has not changed" do
    html = "<p>Hello world!</p>"

    result = Nokodiff.diff(html, html)

    expect(result).to include("<p>Hello world!</p>")
    expect(result).not_to include('<div class="diff">')
    expect(result).not_to include("<del>")
    expect(result).not_to include("<ins>")
  end

  it "wraps changed blocks in del and ins tags" do
    before_html = "<p>Hello world!</p>"
    after_html = "<p>Goodbye world!</p>"

    result = Nokodiff.diff(before_html, after_html)

    expect(result).to include('<div class="diff">')
    expect(result).to include("<del><p>Hello world!</p></del>")
    expect(result).to include("<ins><p>Goodbye world!</p></ins>")
  end

  it "handles completely deleting content" do
    before_html = "<p>Hello world!</p>"
    after_html = ""

    result = Nokodiff.diff(before_html, after_html)

    expect(result).to include('<div class="diff">')
    expect(result).to include("<del><p>Hello world!</p></del>")
    expect(result).not_to include("<ins>")
  end

  it "handles adding entirely new content" do
    before_html = ""
    after_html = "<p>Hello world!</p>"

    result = Nokodiff.diff(before_html, after_html)

    expect(result).to include('<div class="diff">')
    expect(result).not_to include("<del>")
    expect(result).to include("<ins><p>Hello world!</p></ins>")
  end
end
