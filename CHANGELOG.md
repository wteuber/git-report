# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-23

### Added
- First release as the `git-report` gem, installable via `gem install git-report`.
- Gem packaging: `git-report.gemspec`, `VERSION`, `lib/version.rb`, and a
  `Rakefile` running the test suite and RuboCop.
- `gem install` sets up the `git report` alias (via `bin/git_add_alias_report`),
  and `gem uninstall` removes it (via a `rubygems_plugin.rb` `pre_uninstall` hook
  calling `bin/git_remove_alias_report`).
- `git-report --version` / `-v` prints the version.

### Changed
- **BREAKING**: Renamed the project from `git_report` to `git-report` (gem,
  executable, repository, and documentation). The Ruby source file
  `lib/git_report.rb` keeps its underscore per Ruby file-naming convention.
- `bin/install` / `bin/uninstall` renamed to `bin/git_add_alias_report` /
  `bin/git_remove_alias_report`.

[Unreleased]: https://github.com/wteuber/git-report/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/wteuber/git-report/releases/tag/v1.0.0
