# Wikidata for Ruby

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
    (...)

You'll notice that doesn't seem very useful for humans, because Wikidata property keys and many of its values are not human readable. To have the gem resolve all of these opaque identifiers (which adds extra network calls), pass `-r`.

    $ wikidata find "Kyle Chandler" -r
    
That will provide more useful results:
    
    (...)
    +------------------------+------+---------------------------------------------------------------------+
    | sex (or gender)        | P21  | male (Q6581097)                                                     |
    +------------------------+------+---------------------------------------------------------------------+
    | country of citizenship | P27  | United States of America (Q30)                                      |
    +------------------------+------+---------------------------------------------------------------------+
    | occupation             | P106 | actor / actress (Q33999)                                            |
    +------------------------+------+---------------------------------------------------------------------+
    | IMDb identifier        | P345 | nm0151419                                                           |
    +------------------------+------+---------------------------------------------------------------------+
    | place of birth         | P19  | Buffalo (Q40435)                                                    |
    +------------------------+------+---------------------------------------------------------------------+
    | date of birth          | P569 | 1965-09-17T00:00:00+00:00                                           |
    +------------------------+------+---------------------------------------------------------------------+
    (...)

Much better!

### In Ruby

You can use a convenient ActiveRecord-inspired syntax for finding information:

```ruby
los_angeles = Wikidata::Item.find_by_title "Los Angeles"
los_angeles.id # => "Q65"

# Let's find the mayor.
mayor = los_angeles.claims_for_property_id("P6").first.mainsnak.value.entity
mayor.label # => "Eric Garcetti"
```

That's the basics!

## Contributing

1. Fork it ( http://github.com/<my-github-username>/wikidata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
