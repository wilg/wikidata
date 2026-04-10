# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

**New entity types:**
- `Lexeme`, `Form`, and `Sense` classes for Wikidata's dictionary/linguistic data (L-prefixed entities)
- `Lexeme.search` for searching the lexeme namespace
- `Entity.find_by_id` auto-dispatches to Lexeme, Property, or Item based on entity type

**REST API & caching:**
- REST API client (`Wikidata::RestClient`) with ETag conditional caching — single-entity fetches use the Wikibase REST API (v1) and get 304 Not Modified when unchanged
- In-memory cache now enforces TTL (was infinite before)
- Redirected entities cached under both requested and canonical IDs
- `IdentityMap.reset!`, `etag_for`, `refresh_ttl!`

**SPARQL:**
- `Wikidata::Sparql.query`, `.item_ids`, `.items` for running SPARQL queries against the Wikidata query service
- Configurable endpoint via `Configuration.sparql_endpoint`

**Entity accessors:**
- `Entity#aliases`, `#all_labels`, `#all_descriptions`
- `Entity#sitelinks`, `#sitelink`, `#sitelink_badges`
- `Entity#redirected?`, `#redirected_from`
- `Entity#label_language`, `#label_is_fallback?`
- `Property#datatype`

**Item helpers:**
- `Item#best_value_for` and `#values_for` — shortcut for the common ranked-claim-value pattern
- `Item#truthy_claims_for` — renamed from `ranked_claims_for_property_id` to match Wikidata terminology (old name kept as alias)
- `Item.find_by_property_value` and `find_all_by_property_value` for external ID lookups

**Statement model:**
- `Statement#qualifiers`, `#qualifiers_for`, `#references`, `#rank`
- `Statement#start_time`, `#end_time`, `#point_in_time`, `#current?` temporal qualifier helpers

**DataValues improvements:**
- `Quantity#amount_string`, `#upper_bound`, `#lower_bound`, `#unitless?`, `#to_h`
- `Globecoordinate#latitude`, `#longitude`, `#precision`, `#globe_item_id`, `#to_h`
- `Time#precision`, `#calendar_model`, `#julian?`
- `Year#historical_year`, `#bce?`, `#precision`, `#month`
- Precision-aware `Year#to_s`: "18th century", "1950s", "March 2020", "2nd millennium"
- `DataValues::SomeValue` and `DataValues::NoValue` classes
- `DataValues::Quantity` and `DataValues::MonolingualText` classes

**Snak extensibility:**
- `Snak.register_value_handler` registry pattern for adding custom datavalue types
- `Snak#no_value?`, `#some_value?`, `#unknown?` predicates

**API compliance:**
- Default `User-Agent` header per Wikimedia policy
- Configurable `maxlag` parameter for bot-polite requests
- Automatic retry with backoff on 429 rate limits and maxlag errors
- Language fallback via `languagefallback` API parameter
- `Wikidata::HttpError`, `RateLimitError`, `MaxlagError` error classes

**Configuration:**
- `Configuration.api_url` — custom Wikibase instance support
- `Configuration.rest_api_url` — custom REST API endpoint
- `Configuration.use_rest_api` — toggle REST API (default: true)
- `Configuration.sparql_endpoint` — custom SPARQL endpoint
- `Configuration.default_props` and `sitefilter` — reduce API response size
- `Configuration.user_agent` — custom User-Agent string
- `Configuration.maxlag` and `max_retries`
- `Configuration.logger` — Ruby Logger integration (replaces `puts`)
- Per-request `props:` and `sitefilter:` on `find_by_id`, `find_all_by_id`, etc.

**Search:**
- `limit:` and `offset:` parameters for pagination

**CLI:**
- `--format json` option for structured output on all commands

**Infrastructure:**
- Test suite: minitest + webmock + VCR (184 tests, 329 assertions)
- GitHub Actions CI (lint + tests on Ruby 3.1-3.3)
- GitHub Copilot coding agent setup
- `Wikidata::Error` base error class
- `spec.metadata` URIs in gemspec
- CHANGELOG

### Changed
- Require Ruby >= 3.1 (was >= 2.3)
- Drop `activesupport` dependency entirely
- Thread-safe identity map using Mutex
- `frozen_string_literal: true` on all source files
- Raise `Wikidata::HttpError` on API errors instead of returning `[]`
- Filter spec/test files out of gem package

### Fixed
- BCE dates: `Year#to_i` returned 0 for all negative years
- Astronomical year numbering: display now correctly shows "501 BCE" for year -500 (was "500 BCE")
- `Time#to_time` failed on Wikidata's `+` prefix format
- Julian calendar dates now indicated in `Time#to_s`
- `resolve_claims!` deduplicates IDs and includes qualifier entities

## [0.0.4] - 2024

- Add ranked claim filtering and configurable cache store
- Handle nil value in `item_ids_for_property_id`
