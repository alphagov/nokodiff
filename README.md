# Nokodiff

A Ruby Gem to highlight additions, deletions and character level changes while preserving original HTML.

It includes functionality to:
* Compare two HTML fragments and output diffs with semantic HTML
* Inline character differences highlighting using `<strong>` tagging
* Blocks of added or removed content wrapped in aria labelled `<ins>` and `<del>` tags
* Optional CSS for styling the visual differences

## Installation

Install the gem:

```
gem install nokodiff
```

or add it to your Gemfile

```
gem "nokodiff"
```

## Usage

In the controller:
```ruby
require 'nokodiff'

before_html = < YOUR HTML >
after_html = < YOUR HTML >

@differ = Nokodiff.diff(before_html, after_html)
```

In the erb file:
```erb
<div>
  <%= @differ %>
</div>
```

### Including the CSS

In your application.scss file include:
```scss
@import "nokodiff";
```

This will include the styling for `<del>`, `<ins>` and `<strong>` tags to allow colour coding, highlighting and underlining of changes.

## Licence

The gem is available as open source under the terms of the [MIT License.](https://opensource.org/license/MIT)