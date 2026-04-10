# frozen_string_literal: true

require_relative "lib/wikidata/version"

Gem::Specification.new do |spec|
  spec.name = "wikidata"
  spec.version = Wikidata::VERSION
  spec.authors = ["Wil Gieseler"]
  spec.email = ["wil@wilgieseler.com"]
  spec.summary = "Ruby client for Wikidata"
  spec.homepage = "https://github.com/wilg/wikidata"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wilg/wikidata"
  spec.metadata["changelog_uri"] = "https://github.com/wilg/wikidata/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.start_with?(*%w[spec/ .github/ .claude/])
    end
  end
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "colorize"
  spec.add_dependency "terminal-table"
  spec.add_dependency "thor"
  spec.add_dependency "i18n"
  spec.add_dependency "hashie", ">= 2.0"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "minitest", ">= 5.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 6.0"
end
