# Changelog

## 0.4.1

- Fix text node diffs when nodes contain line breaks

## 0.4.0

- Corrects functionality to identify added or deleted nodes (e.g entirely new paragraph)
- Adds recursion to step into embedded HTML structures to ensure only highlighting changes at the most granular level

## 0.3.1

- Use `span` instead of `strong` for highlighting changes

## 0.3.0

- Allow for more complex diffing strategies using `data-diff-key` attributes
- Remove empty nodes and comments from HTML before diffing

## 0.2.0

- Generate HTML diffs between two fragments using semantic `<del>` and `<ins>` tags
- Highlight character-level changes using `<strong>` tags
- Preserve the existing HTML structures, including links, spans and block elements
- Return HTMl-safe output in Rails environments, allowing diffs to be rendered directly in ERB templates
- Optional Rails engine to expose default stylesheets through the asset pipeline

## 0.1.0

- Initial release
