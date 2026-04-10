# Wikidata for Ruby [![Gem Version](https://badge.fury.io/rb/wikidata.svg)](http://badge.fury.io/rb/wikidata)

A Ruby client for the [Wikidata](https://www.wikidata.org) API. Supports items, properties, lexemes, SPARQL queries, and includes a CLI.

## Installation

```ruby
gem 'wikidata'
```

Requires Ruby 3.1+.

## Quick Start

```ruby
require 'wikidata'

item = Wikidata::Item.find_by_id("Q42")
item.label          # => "Douglas Adams"
item.description    # => "English writer and humourist"
item.aliases        # => ["Douglas Noel Adams", "Douglas N. Adams", ...]

# Get the best value for a property
item.best_value_for("P569").to_s  # => "1952-03-11"

# Get all values for a multi-value property
item.values_for("P106").map(&:item_id)  # => ["Q36180", "Q214917", ...]
```

## Finding Entities

```ruby
# By ID
item = Wikidata::Item.find_by_id("Q42")

# By Wikipedia title
item = Wikidata::Item.find_by_title("Douglas Adams")

# Search
results = Wikidata::Item.search("Los Angeles", limit: 20, offset: 0)

# By external ID (IMDb, Freebase, ISBN, etc.)
item = Wikidata::Item.find_by_property_value("P345", "tt0371724")

# Batch fetch
items = Wikidata::Item.find_all_by_id("Q42|Q1|Q5")
```

## Working with Claims

```ruby
item = Wikidata::Item.find_by_id("Q42")

# Best-ranked value (truthy — matches SPARQL's wdt: prefix)
item.best_value_for("P31")          # => DataValues::Entity for "human"
item.best_value_for("P569").to_s    # => "1952-03-11"

# All truthy values
item.values_for("P106")             # => [DataValues::Entity, ...]

# Raw claims with full statement data
claims = item.truthy_claims_for("P569")
claim = claims.first
claim.rank                    # => "normal"
claim.mainsnak.value          # => DataValues::Time
claim.qualifiers              # => [Snak, ...]
claim.qualifiers_for("P459")  # => qualifier snaks for "determination method"
claim.references              # => [[Snak, ...], ...]

# Temporal helpers
claim = item.truthy_claims_for("P39").first  # position held
claim.start_time    # => DataValues::Time or nil
claim.end_time      # => DataValues::Time or nil
claim.current?      # => true if no end_time
```

## Value Types

All Wikidata value types are deserialized into typed Ruby objects:

```ruby
# Entity references
val = item.best_value_for("P31")
val.item_id  # => "Q5"
val.entity   # => fetches the full Item

# Time (precision >= 11, day)
val = item.best_value_for("P569")
val.to_time     # => DateTime
val.to_s        # => "1952-03-11"
val.julian?     # => false
val.precision   # => 11

# Year/Date (precision < 11)
val.to_s        # => "1952" or "18th century" or "1950s" or "March 2020"
val.to_i        # => 1952
val.bce?        # => false
val.historical_year # => converts astronomical year numbering to conventional

# Quantity
val = item.best_value_for("P2048")
val.amount          # => 1.96
val.amount_string   # => "1.96" (no + prefix)
val.unit_item_id    # => "Q11573" (metre)
val.unitless?       # => false
val.to_h            # => {amount: "1.96", unit: "Q11573"}

# Globe coordinates
val = item.best_value_for("P625")
val.latitude   # => 34.05
val.longitude  # => -118.25
val.to_h       # => {latitude: 34.05, longitude: -118.25, precision: ..., globe: "Q2"}

# Strings, Commons media, Monolingual text
val.to_s  # works on all value types
```

## Sitelinks, Aliases & Labels

```ruby
item = Wikidata::Item.find_by_id("Q42")

item.sitelink("enwiki").title    # => "Douglas Adams"
item.sitelink_badges("enwiki")   # => ["Q17437796"] (featured article)
item.all_labels                  # => {"en" => "Douglas Adams", "de" => "Douglas Adams", ...}
item.all_descriptions            # => {"en" => "English writer", ...}
item.aliases(:en)                # => ["Douglas Noel Adams", ...]

# Language fallback detection
item.label(:qu)                  # => "Douglas Adams" (fell back from Quechua)
item.label_is_fallback?(:qu)     # => true
item.label_language(:qu)         # => "mul" (actual source language)
```

## Lexemes (Dictionary Data)

```ruby
cat = Wikidata::Entity.find_by_id("L7")
cat.lemma              # => "cat"
cat.language_item_id   # => "Q1860" (English)
cat.lexical_category_item_id  # => "Q1084" (noun)

# Forms (morphological variants)
cat.forms.map(&:representation)  # => ["cat", "cats"]
cat.forms.last.grammatical_features  # => ["Q146786"] (plural)

# Senses (definitions)
cat.senses.first.gloss          # => "domesticated subspecies of feline animal"
cat.senses.first.all_glosses    # => {"en" => "domesticated...", "es" => "gato doméstico"}

# Search lexemes
results = Wikidata::Lexeme.search("run", language: "en")
```

## SPARQL Queries

```ruby
# Raw query — returns bindings
results = Wikidata::Sparql.query("SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 5")

# Extract item IDs
ids = Wikidata::Sparql.item_ids("SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 5")
# => ["Q65", "Q60", ...]

# Fetch full entities
cities = Wikidata::Sparql.items("SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 5")
cities.first.label  # => "Los Angeles"
```

## Configuration

```ruby
Wikidata.configure do |config|
  # Custom User-Agent (recommended — Wikimedia requires a meaningful one)
  config.user_agent = "MyApp/1.0 (https://myapp.com; contact@myapp.com)"

  # Reduce response size by fetching only what you need
  config.default_props = "labels|descriptions|claims"
  config.sitefilter = "enwiki"

  # Bot-polite settings
  config.maxlag = 5         # back off when servers are lagged
  config.max_retries = 3    # auto-retry on 429/maxlag (default)

  # Caching
  config.cache_store = Rails.cache  # or nil for in-memory
  config.cache_ttl = 3600           # seconds (default)

  # REST API (enabled by default for single-entity fetches with ETag caching)
  config.use_rest_api = true

  # Custom Wikibase instance
  config.api_url = "https://my-wikibase.example.com/w/api.php"
  config.rest_api_url = "https://my-wikibase.example.com/w/rest.php/wikibase/v1"
  config.sparql_endpoint = "https://my-wikibase.example.com/query/sparql"

  # Logging
  config.logger = Rails.logger  # default: Logger.new($stdout, level: WARN)
  config.verbose = true         # log all API URLs at debug level

  # HTTP
  config.faraday_adapter = :net_http  # default
  config.client_options = { request: { open_timeout: 1, timeout: 9 } }

  # Property presets for convenience methods
  config.property_presets = {
    mother: "P25",
    father: "P22",
    instance_of: "P31",
    subclass_of: "P279"
  }
end
```

Per-request overrides:

```ruby
# Fetch only labels and claims for this request
item = Wikidata::Item.find_by_id("Q42", props: "labels|claims", sitefilter: "enwiki")
```

## Extending Value Types

Register custom handlers for new or domain-specific datavalue types:

```ruby
Wikidata::Snak.register_value_handler("my-custom-type") do |datavalue, snak|
  MyCustomValue.new(datavalue.value)
end
```

## CLI

```
wikidata find "Los Angeles"          # find by Wikipedia title
wikidata get Q65                     # find by Wikidata ID
wikidata search "kerrygold"          # search
wikidata lucky "Douglas Adams"       # search and return first result
wikidata traverse "Prince George of Cambridge" father  # follow property links

# Options
--format json    # output raw JSON instead of tables
-f               # fast mode (skip resolving property labels)
-v               # verbose (show API URLs)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run tests (`bundle exec rake spec`) and lint (`bundle exec standardrb`)
4. Commit your changes
5. Push to the branch
6. Create a Pull Request
