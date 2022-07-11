# 0.0.11

- Add `excluding_issue_ids` parameter to skip showing issues with the given IDs, e.g. "MissingTranslation" ([@petitJAM](https://github.com/petitJAM))

# 0.0.10

- Fix `filtering_lines` parameter to also apply to when `inline_mode` is `false` ([@petitJAM](https://github.com/petitJAM))

# 0.0.9
- Add `filtering_lines` parameter, to show lint issues only on modified lines ([@ShivamPokhriyal](https://github.com/ShivamPokhriyal))

# 0.0.8
- Fix security issues ([@barbosa](https://github.com/barbosa))
- Expose report message ([@adamstrange])(https://github.com/adamstrange))
- Skip gradle task ([@mathroule])(https://github.com/mathroule))

# 0.0.7
- Fix security issues ([@barbosa](https://github.com/barbosa))

# 0.0.6
- Bump yarn and rubocop versions due to security issues ([@barbosa](https://github.com/barbosa))

# 0.0.5
- Fix count number for issues ([@jettbow](https://github.com/jettbow))
- Add option for skipping gradle task ([@litmon](https://github.com/litmon))

# 0.0.4
- Add `filtering` parameter, default to false, to run lint only on modified files ([@leonhartX](https://github.com/leonhartX))
- Add support for GitHub's inline comments ([@leonhartX](https://github.com/leonhartX))

# 0.0.3
- Add `report_file` parameter, so users can set a custom path for their report xmls ([@churowa](https://github.com/churowa))

## 0.0.2
- Fix check for inexistent report file ([@barbosa](https://github.com/barbosa))
- Fix markdown message being printed without any issues reported ([@barbosa](https://github.com/barbosa))

## 0.0.1
- Initial version ([@barbosa](https://github.com/barbosa))
