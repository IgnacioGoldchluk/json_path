# Changelog

All notable changes to this project will be documented in this file.

## 0.4.0 [2026-06-09]
`JSONPath.evaluate/3` has been deprecated. Use the following new functions instead based on the previous value of the `returning` argument:
- `:values` -> `JSONPath.values/2`
- `:paths` -> `JSONPath.paths/2`
- `:values_and_paths` -> `JSONPath.value_paths/2`

Same applies for `JSONPath.evaluate!/3`

## 0.3.0 [2026-06-07]
- feat: Add optional `returning` argument to `JSONPath.evaluate` function, which can be one of the following:
    - `:values` (default) - The node values are returned, same behavior as previous versions
    - `:paths` - Normalized paths are returned instead. See [normalized paths](https://www.rfc-editor.org/info/rfc9535/#name-normalized-paths)
    - `:values_and_paths` - List of two-element tuples with format `{node_value, normalized_path}`

## 0.2.0 [2026-05-29]
- fix: `match` function returning false when a substring is also valid
- feat: Add `JSONPath.build!/1` and `JSONPath.evaluate!/2`
- internal: pre-compile regular expressions in `match` and `search` when a string is provided for better performance

## 0.1.2 [2026-05-26]
- fix: `match` function where regex contains capturing groups

## 0.1.1 [2026-05-24]
- fix: allow for any comparison in filters, including literals on both sides, for example `$[?(1 == 1)]`

## 0.1.0 [2026-05-24]
- Initial working version