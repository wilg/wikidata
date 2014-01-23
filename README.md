# Wikidata for Ruby [![Gem Version](https://badge.fury.io/rb/wikidata.png)](http://badge.fury.io/rb/wikidata)

Access all of the wonderful structured data on [Wikidata](http://www.wikidata.org), with Ruby! Also includes a convenient CLI.

Very much a work in progress, so only a few basic things are working.

## Installation

Add this line to your application's Gemfile:

    gem 'wikidata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wikidata

## Usage

### Command Line

See all the claims for a particular topic.

    $ wikidata find "Kyle Chandler"

This will fetch all the data (called "claims") Wikidata has on superstar actor Kyle Chandler and print it out in the terminal, like so:

    Kyle Chandler
    Wikidata ID: Q359604
    Claims: 14
    +------------------------+------+---------------------------------------------------------------------+
    | Property Label         | id   | value                                                               |
    +------------------------+------+---------------------------------------------------------------------+
    | sex (or gender)        | P21  | male (Q6581097)                                                     |
    +------------------------+------+---------------------------------------------------------------------+
    | country of citizenship | P27  | United States of America (Q30)                                      |
    +------------------------+------+---------------------------------------------------------------------+
    | occupation             | P106 | actor / actress (Q33999)                                            |
    +------------------------+------+---------------------------------------------------------------------+
    | Commons category       | P373 | Kyle Chandler                                                       |
    +------------------------+------+---------------------------------------------------------------------+
    | VIAF identifier        | P214 | 56819238                                                            |
    +------------------------+------+---------------------------------------------------------------------+
    | ISNI (ISO 27729)       | P213 | 0000 0001 1444 9499                                                 |
    +------------------------+------+---------------------------------------------------------------------+
    | LCCN identifier        | P244 | no2007102838                                                        |
    +------------------------+------+---------------------------------------------------------------------+
    | GND identifier         | P227 | 1016952201                                                          |
    +------------------------+------+---------------------------------------------------------------------+
    | IMDb identifier        | P345 | nm0151419                                                           |
    +------------------------+------+---------------------------------------------------------------------+
    | image                  | P18  | Kyle Chandler at the Texas Film Hall of Fame Awards, March 2009.jpg |
    +------------------------+------+---------------------------------------------------------------------+
    | instance of            | P31  | human (Q5)                                                          |
    +------------------------+------+---------------------------------------------------------------------+
    | place of birth         | P19  | Buffalo (Q40435)                                                    |
    +------------------------+------+---------------------------------------------------------------------+
    | date of birth          | P569 | 1965-09-17T00:00:00+00:00                                           |
    +------------------------+------+---------------------------------------------------------------------+
    | Freebase identifier    | P646 | /m/069nzr                                                           |
    +------------------------+------+---------------------------------------------------------------------+

For internationalization reasons, Wikidata property keys and many of its values are not human readable by default. (For example, the place of birth property is actually "P19".)

The CLI will automatically resolve the opaque identifiers by fetching their full descriptions from Wikidata as well. This adds a few more HTTP requests, so if you wish you can also pass `-f` to skip the resolving and return only opaque IDs, like so:

    Wikidata ID: Q359604
    Claims: 14
    +-------------+---------------------------------------------------------------------+
    | property_id | value                                                               |
    +-------------+---------------------------------------------------------------------+
    | P21         | Q6581097                                                            |
    +-------------+---------------------------------------------------------------------+
    | P27         | Q30                                                                 |
    +-------------+---------------------------------------------------------------------+
    | P106        | Q33999                                                              |
    +-------------+---------------------------------------------------------------------+
    | P373        | Kyle Chandler                                                       |
    +-------------+---------------------------------------------------------------------+
    | P214        | 56819238                                                            |
    +-------------+---------------------------------------------------------------------+

### In Ruby

You can use a convenient ActiveRecord-inspired syntax for finding information:

```ruby
require 'wikidata'

los_angeles = Wikidata::Item.find_by_title "Los Angeles"
los_angeles.id # => "Q65"

# Let's find the mayor.
# The "head of government" property has an Wikidata property id of "P6".
mayor = los_angeles.claims_for_property_id("P6").first.mainsnak.value.entity
mayor.label # => "Eric Garcetti"

# There's a few convenience methods for fetching common associated entities
item = Wikidata::Item.find_by_title("Chelsea Clinton")
item.mothers.first.label # => "Hillary Rodham Clinton"

# There's also a convenience method for finding the default image
sf = Wikidata::Item.find_by_title("San Francisco")
sf.image
# => an instance of Wikidata::DataValues::CommonsMedia
sf.image.resolved
# => an instance of Wikidata::DataValues::CommonsMedia with additional data fetched
sf.image.resolved.file.urls.file
# => "http://upload.wikimedia.org/wikipedia/commons/3/3b/San_Francisco_%28Evening%29.jpg"

```

That's the basics!

## Contributing

1. Fork it ( http://github.com/<my-github-username>/wikidata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
