# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Test suite with minitest, webmock, and VCR
- GitHub Actions CI (lint + tests on Ruby 3.1-3.3)
- GitHub Copilot coding agent setup
- `Wikidata::Error` base error class
- `IdentityMap.reset!` for clearing the in-memory cache
- `Snak#no_value?`, `Snak#some_value?`, `Snak#unknown?` predicates
- `DataValues::SomeValue` and `DataValues::NoValue` classes
- `spec.metadata` URIs in gemspec

### Changed
- Require Ruby >= 3.1 (was >= 2.3)
- Drop `activesupport` dependency entirely
- Replace `in_groups_of` with `each_slice` (pure Ruby)
- Replace `Array.wrap` with `Array()` (pure Ruby)
- Replace `.present?` with `.empty?` (pure Ruby)
- Thread-safe identity map using Mutex (was bare class variable)
- Use `.key?` instead of deprecated `.has_key?`
- Raise `Wikidata::Error` instead of bare strings
- Add `frozen_string_literal: true` to all source files
- Filter spec/test files out of gem package

### Fixed
- Redundant `to_s` lint warnings in CLI

## [0.0.4] - 2024

- Add ranked claim filtering and configurable cache store
- Handle nil value in `item_ids_for_property_id`
