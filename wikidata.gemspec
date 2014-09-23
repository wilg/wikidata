# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikidata/version'

Gem::Specification.new do |spec|
  spec.name          = "wikidata"
  spec.version       = Wikidata::VERSION
  spec.authors       = ["Wil Gieseler"]
  spec.email         = ["wil@wilgieseler.com"]
  spec.summary       = "Ruby client for Wikidata"
  spec.homepage      = "http://github.com/wilg/wikidata"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "patron"
  spec.add_dependency "colorize"
  spec.add_dependency "terminal-table"
  spec.add_dependency "activesupport"
  spec.add_dependency "thor"
  spec.add_dependency "i18n"
  spec.add_dependency "hashie", ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
