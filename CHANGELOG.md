# Changelog

All notable changes to this project will be documented in this file.

## 0.3.0 [2025-06-07]
- feat: Add optional `returning` argument to `JSONPath.evaluate` function, which can be one of the following:
    - `:values` (default) - The node values are returned, same behavior as previous versions
    - `:paths` - Normalized paths are returned instead. See [normalized paths](https://www.rfc-editor.org/info/rfc9535/#name-normalized-paths)
    - `:values_and_paths` - List of two-element tuples with format `{node_value, normalized_path}`

## 0.2.0 [2025-05-29]
- fix: `match` function returning false when a substring is also valid
- feat: Add `JSONPath.build!/1` and `JSONPath.evaluate!/2`
- internal: pre-compile regular expressions in `match` and `search` when a string is provided for better performance

## 0.1.2 [2025-05-26]
- fix: `match` function where regex contains capturing groups

## 0.1.1 [2025-05-24]
- fix: allow for any comparison in filters, including literals on both sides, for example `$[?(1 == 1)]`

## 0.1.0 [2025-05-24]
- Initial working version