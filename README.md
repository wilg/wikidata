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

##### Finding and Fetching

To see all the claims for a particular topic:

    $ wikidata find "Kyle Chandler"

This will fetch all the data (called "claims") Wikidata has on superstar actor Kyle Chandler and print it out in the terminal, like so:

    Kyle Chandler
    American actor
    Wikidata ID: Q359604
    Claims: 15
    +------+------------------------+---------------------------------------------------------------------+
    | ID   | Property Label         | Value                                                               |
    +------+------------------------+---------------------------------------------------------------------+
    | P21  | sex or gender          | male (Q6581097)                                                     |
    | P27  | country of citizenship | United States of America (Q30)                                      |
    | P106 | occupation             | actor (Q33999)                                                      |
    | P373 | Commons category       | Kyle Chandler                                                       |
    | P214 | VIAF identifier        | 56819238                                                            |
    | P213 | ISNI (ISO 27729)       | 0000 0001 1444 9499                                                 |
    | P244 | LCNAF identifier       | no2007102838                                                        |
    | P227 | GND identifier         | 1016952201                                                          |
    | P345 | IMDb identifier        | nm0151419                                                           |
    | P18  | image                  | Kyle Chandler at the Texas Film Hall of Fame Awards, March 2009.jpg |
    | P31  | instance of            | human (Q5)                                                          |
    | P19  | place of birth         | Buffalo (Q40435)                                                    |
    | P569 | date of birth          | 1965-09-17T00:00:00+00:00                                           |
    | P646 | Freebase identifier    | /m/069nzr                                                           |
    | P268 | BnF identifier         | 14163323b                                                           |
    +------+------------------------+---------------------------------------------------------------------+

For internationalization reasons, Wikidata property keys and many of its values are not human readable by default. (For example, the place of birth property is actually "P19".)

The CLI will automatically resolve the opaque identifiers by fetching their full descriptions from Wikidata as well. This adds a few more HTTP requests, so if you wish you can also pass `-f` to skip the resolving and return only opaque IDs, like so:

    $ wikidata find "Kyle Chandler" -f

    Kyle Chandler
    American actor
    Wikidata ID: Q359604
    Claims: 15
    +-------------+---------------------------------------------------------------------+
    | Property ID | Value                                                               |
    +-------------+---------------------------------------------------------------------+
    | P21         | Q6581097                                                            |
    | P27         | Q30                                                                 |
    | P106        | Q33999                                                              |
    | P373        | Kyle Chandler                                                       |
    | P214        | 56819238                                                            |
    | P213        | 0000 0001 1444 9499                                                 |
    | P244        | no2007102838                                                        |
    | P227        | 1016952201                                                          |
    | P345        | nm0151419                                                           |
    | P18         | Kyle Chandler at the Texas Film Hall of Fame Awards, March 2009.jpg |
    | P31         | Q5                                                                  |
    | P19         | Q40435                                                              |
    | P569        | 1965-09-17T00:00:00+00:00                                           |
    | P646        | /m/069nzr                                                           |
    | P268        | 14163323b                                                           |
    +-------------+---------------------------------------------------------------------+

If we'd already known Kyle's Wikidata identifier, we could have done

    $ wikidata get Q359604

and gotten the same results.

##### Traversal

We can also traverse properties. Let's say we wanted to see that stupid royal baby's paternal lineage:

    $ wikidata traverse "Prince George of Cambridge" father

This will continue following links to the specified property, until an entity doesn't contain it. This example will return:

    Prince George of Cambridge (Q13590412)
    Prince William, Duke of Cambridge (Q36812)
    Charles, Prince of Wales (Q43274)
    Prince Philip, Duke of Edinburgh (Q80976)
    Prince Andrew of Greece and Denmark (Q156531)
    George I of Greece (Q17142)
    Christian IX of Denmark (Q151305)
    Friedrich Wilhelm, Duke of Schleswig-Holstein-Sonderburg-Glücksburg (Q240302)
    Friedrich Karl Ludwig, Duke of Schleswig-Holstein-Sonderburg-Beck (Q62109)
    Prince Karl Anton August of Schleswig-Holstein-Sonderburg-Beck (Q64223)
    Peter August, Duke of Schleswig-Holstein-Sonderburg-Beck (Q62380)
    Frederick Louis, Duke of Schleswig-Holstein-Sonderburg-Beck (Q63742)
    August Philipp, Duke of Schleswig-Holstein-Sonderburg-Beck (Q63756)
    Alexander, Duke of Schleswig-Holstein-Sonderburg (Q62499)
    John II, Duke of Schleswig-Holstein-Sonderburg (Q708265)
    Christian III of Denmark (Q154998)
    Frederick I of Denmark (Q157789)
    Christian I of Denmark (Q153940)
    Dietrich, Count of Oldenburg (Q564115)
    Christian V, Count of Oldenburg (Q325817)
    Conrad I, Count of Oldenburg (Q820554)
    John II of Oldenburg (Q1694708)
    Christian III, Count of Oldenburg (Q1080420)
    John I, Count of Oldenburg (Q744583)
    Christian II, Count of Oldenburg (Q99735)
    Maurice, Count of Oldenburg (Q87064)
    Christian I, Count of Oldenburg (Q99687)
    Elimar II, Count of Oldenburg (Q529141)
    Elimar I, Count of Oldenburg (Q881962)

Wow! That's crazy. Monarchies are weird.

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
sf.image.url
# => "http://upload.wikimedia.org/wikipedia/commons/3/3b/San_Francisco_%28Evening%29.jpg"
```

You can configure some options by creating an initializer like this:

```ruby
Wikidata.configure do |config|
  config.use_only_default_language = false
  config.verbose = true
  config.client_options = {
    request: {
      open_timeout: 1,
      timeout: 9
    }
  }
end
```

## Contributing

1. Fork it ( http://github.com/wilg/wikidata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
