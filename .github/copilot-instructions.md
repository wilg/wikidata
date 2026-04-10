# Copilot Instructions for wikidata gem

## Overview

This is a Ruby gem that provides a client for the Wikidata API. It wraps
the `wbgetentities` and `query` API actions and deserializes responses
into typed Ruby objects (Item, Entity, Statement, Snak, DataValues).

## Development

- Ruby 3.1+
- Install dependencies: `bundle install`
- Run tests: `bundle exec rake spec`
- Run linter: `bundle exec standardrb`
- Auto-fix lint: `bundle exec standardrb --fix`

## Code standards

- Follow Standard Ruby style (enforced by `standardrb`)
- All new behavior must have tests in `spec/`
- Tests use minitest, webmock for HTTP stubbing, and VCR for recorded API responses
- Unit tests (snak parsing, datavalues) use inline test data
- Integration tests (entity API calls) use VCR cassettes in `spec/cassettes/`
- To record new VCR cassettes, delete the `.yml` file and run with `record: :new_episodes`

## Architecture

- `lib/wikidata/entity.rb` — API client, HTTP via Faraday, find/search methods
- `lib/wikidata/item.rb` �� claims access, property filtering, convenience methods
- `lib/wikidata/snak.rb` — value deserialization, routes datavalue types
- `lib/wikidata/datavalues/` — typed value classes (Entity, Time, Year, String, etc.)
- `lib/wikidata/identity_map.rb` — in-memory + optional Redis caching
- `lib/wikidata/configuration.rb` — settings, property presets

## Before committing

1. `bundle exec rake spec` — all tests must pass
2. `bundle exec standardrb` — no lint violations
