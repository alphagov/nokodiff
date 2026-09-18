# Changelog
## 1.0.0 – 2026-09-18

### Breaking Changes
* **Ruby Version Requirement:** Upgraded required Ruby version to `3.3`.
* **Dropped Legacy Ruby Support:** Removed support for Ruby 3.2.x versions.

### Other changes
* **Screen Reader Accessibility:** Replaced previous `aria-label` attributes with visually hidden screen reader text elements.
* **GOV.UK Publishing Component Overrides:** Added custom styling overrides for all components within the GOV.UK publishing components guide.
* **Local Development Environment:** Added a `spec/dummy` Rails application and the `bin/run-dummy-app` task script to preview diff outputs locally in a browser.
* **Inline Element Wrapping:** Swapped `<div>` wrappers outside changed elements for inline `<span>` elements placed inside changed elements to improve compatibility with HTML tables and lists.
* **Visual Diff Styling:** Updated default visual styling for diff highlights, deletions, and change markers.
* **Nested Semantic HTML Comparison:** Enhanced semantic comparison for bottom-level tags (e.g., `<p>`) containing nested inline sub-elements (e.g., `<b>`, `<a>`) so sub-element formatting and styling are preserved during diff calculations.

## 0.4.2

- Ensure changes to headings and lists are treated as a single change

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
