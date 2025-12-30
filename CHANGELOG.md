# Changelog

## 0.1.0

- Generate HTML diffs between two fragments using semantic `<del>` and `<ins>` tags
- Highlight character-level changes using `<strong` tags
- Preserve the existing HTML structures, including links, spans and block elements
- Return HTMl-safe output in Rails environments, allowing diffs to be rendered directly in ERB templates
- Optional Rails engine to expose default stylesheets through the asset pipeline
