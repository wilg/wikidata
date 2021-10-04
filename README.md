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

To see all options, just type `wikidata`:

    Commands:
    wikidata find ARTICLE_NAME                    # find a Wikidata entity by name
    wikidata get ID                               # find a Wikidata entity by ID
    wikidata help [COMMAND]                       # Describe available commands or one specific command
    wikidata lucky QUERY                          # searches Wikidata and returns the first matching object
    wikidata search QUERY                         # searches Wikidata and returns a list of matching objects
    wikidata traverse ARTICLE_NAME relation_name  # find all related items until there are no more

##### Searching

To search for something:

    › wikidata search "kerrygold"
    ╭───────────┬─────────────────────────────────┬──────────────╮
    │ ID        │ Label                           │ Description  │
    ╞═══════════╪═════════════════════════════════╪══════════════╡
    │ Q1229505  │ Kerrygold                       │ butter brand │
    │ Q2755639  │ Kerrygold International Classic │              │
    │ Q21233172 │ Kerrygold Irish Cream Liqueur   │              │
    ╰───────────┴─────────────────────────────────┴──────────────╯

You can then get the article like so:

    › wikidata get Q1229505
    Kerrygold
    butter brand
    Wikidata ID: Q1229505
    Claims: 10
    ╭───────┬───────────────────────────┬───────────────────────────────╮
    │ ID    │ Property Label            │ Value                         │
    ╞═══════╪═══════════════════════════╪═══════════════════════════════╡
    │ P31   │ instance of               │ trademark (Q167270)           │
    │       │                           │ food brand (Q16323605)        │
    │ P2002 │ Twitter username          │ KerrygoldUSA                  │
    │       │                           │ KerrygoldIRL                  │
    │       │                           │ KerrygoldUK                   │
    │ P127  │ owned by                  │ Ornua (Q179410)               │
    │ P279  │ subclass of               │ butter (Q34172)               │
    │ P154  │ logo image                │ KG Logo 2010.jpg              │
    │ P856  │ official website          │ https://www.kerrygoldusa.com/ │
    │ P2671 │ Google Knowledge Graph ID │ /g/121bj_r0                   │
    ╰───────┴───────────────────────────┴───────────────────────────────╯

##### Finding and Fetching

To see all the claims for a particular item that you know the name of:

    › wikidata find "Kyle Chandler"

This will fetch all the data (called "claims") Wikidata has on superstar actor Kyle Chandler and print it out in the terminal, like so:

    Kyle Chandler
    American actor
    Wikidata ID: Q359604
    Claims: 58
    ╭───────┬───────────────────────────────────────┬───────────────────────────────────────╮
    │ ID    │ Property Label                        │ Value                                 │
    ╞═══════╪═══════════════════════════════════════╪═══════════════════════════════════════╡
    │ P27   │ country of citizenship                │ United States of America (Q30)        │
    │ P106  │ occupation                            │ actor (Q33999)                        │
    │       │                                       │ film actor (Q10800557)                │
    │       │                                       │ television actor (Q10798782)          │
    │       │                                       │ film producer (Q3282637)              │
    │ P373  │ Commons category                      │ Kyle Chandler                         │
    │ P214  │ VIAF ID                               │ 56819238                              │
    │ P213  │ ISNI                                  │ 0000 0001 1444 9499                   │
    │ P244  │ Library of Congress authority ID      │ no2007102838                          │
    │ P227  │ GND ID                                │ 1016952201                            │
    │ P345  │ IMDb ID                               │ nm0151419                             │
    │ P18   │ image                                 │ Kyle Chandler, March 2009.jpg         │
    │ P31   │ instance of                           │ human (Q5)                            │
    │ P19   │ place of birth                        │ Buffalo (Q40435)                      │
    │ P569  │ date of birth                         │ 1965-09-17T00:00:00+00:00             │
    │ P646  │ Freebase ID                           │ /m/069nzr                             │
    │ P735  │ given name                            │ Kyle (Q1326816)                       │
    │ P1220 │ Internet Broadway Database person ID  │ 71312                                 │
    │ P1266 │ AlloCiné person ID                    │ 97817                                 │
    │ P2019 │ AllMovie person ID                    │ p12245                                │
    │ P2168 │ Swedish Film Database person ID       │ 223629                                │
    │ P2002 │ Twitter username                      │ kylechandler                          │
    │ P1649 │ KMDb person ID                        │ 00095263                              │
    │ P2387 │ Elonet person ID                      │ 969292                                │
    │ P2435 │ PORT person ID                        │ 27319                                 │
    │ P2519 │ Scope.dk person ID                    │ 32607                                 │
    │ P2605 │ ČSFD person ID                        │ 25095                                 │
    │ P2626 │ Danish National Filmography person ID │ 110657                                │
    │ P2604 │ Kinopoisk person ID                   │ 28949                                 │
    │ P734  │ family name                           │ Chandler (Q11259438)                  │
    │ P3142 │ EDb person ID                         │ n0016406                              │
    │ P3144 │ elFilm person ID                      │ 3999176                               │
    │ P3136 │ elCinema person ID                    │ 2009821                               │
    │ P3305 │ KINENOTE person ID                    │ 200784                                │
    │ P69   │ educated at                           │ University of Georgia (Q761534)       │
    │       │                                       │ George Walton Academy (Q5545865)      │
    │ P2949 │ WikiTree person ID                    │ Chandler-5088                         │
    │ P1263 │ NNDB people ID                        │ 629/000067428                         │
    │ P551  │ residence                             │ Dripping Springs (Q951210)            │
    │ P4985 │ TMDb person ID                        │ 3497                                  │
    │ P269  │ IdRef ID                              │ 157064751                             │
    │ P5534 │ Open Media Database person ID         │ 3497                                  │
    │ P1006 │ Nationale Thesaurus voor Auteurs ID   │ 314141863                             │
    │ P3417 │ Quora topic ID                        │ Kyle-Chandler-actor                   │
    │ P21   │ sex or gender                         │ male (Q6581097)                       │
    │ P268  │ Bibliothèque nationale de France ID   │ 14163323b                             │
    │ P691  │ NKCR AUT ID                           │ xx0155549                             │
    │ P7214 │ Allcinema person ID                   │ 63597                                 │
    │ P1343 │ described by source                   │ Obalky knih.cz (Q67311526)            │
    │ P7859 │ WorldCat Identities ID                │ lccn-no2007102838                     │
    │ P1580 │ University of Barcelona authority ID  │ a1392541                              │
    │ P2031 │ work period (start)                   │ 1988                                  │
    │ P5033 │ Filmweb.pl person ID                  │ 63637                                 │
    │ P1207 │ NUKAT ID                              │ n2019020135                           │
    │ P8687 │ social media followers                │                                       │
    │ P5905 │ Comic Vine ID                         │ 4040-84681                            │
    │ P5421 │ Trading Card Database person ID       │ 164090                                │
    ╰───────┴───────────────────────────────────────┴───────────────────────────────────────╯

For internationalization reasons, Wikidata property keys and many of its values are not human readable by default. (For example, the place of birth property is actually "P19".)

The CLI will automatically resolve the opaque identifiers by fetching their full descriptions from Wikidata as well. This adds a few more HTTP requests, so if you wish you can also pass `-f` to skip the resolving and return only opaque IDs, like so:

    › wikidata find "Kyle Chandler" -f
    Kyle Chandler
    American actor
    Wikidata ID: Q359604
    Claims: 58
    ╭─────────────┬─────────────────────────────────────────────────────────╮
    │ Property ID │ Value                                                   │
    ╞═════════════╪═════════════════════════════════════════════════════════╡
    │ P27         │ Q30                                                     │
    │ P106        │ Q33999                                                  │
    │             │ Q10800557                                               │
    │             │ Q10798782                                               │
    │             │ Q3282637                                                │
    │ P373        │ Kyle Chandler                                           │
    │ P214        │ 56819238                                                │
    │ P213        │ 0000 0001 1444 9499                                     │
    │ P244        │ no2007102838                                            │
    │ P227        │ 1016952201                                              │
    │ P345        │ nm0151419                                               │
    │ P18         │ Kyle Chandler, March 2009.jpg                           │
    │ P31         │ Q5                                                      │
    │ P19         │ Q40435                                                  │
    │ P569        │ 1965-09-17T00:00:00+00:00                               │
    │ P646        │ /m/069nzr                                               │
    │ P735        │ Q1326816                                                │
    │ P1220       │ 71312                                                   │
    │ P1266       │ 97817                                                   │
    │ P2019       │ p12245                                                  │
    │ P2168       │ 223629                                                  │
    │ P2002       │ kylechandler                                            │
    │ P1649       │ 00095263                                                │
    │ P2949       │ Chandler-5088                                           │
    │ P1263       │ 629/000067428                                           │
    │ P551        │ Q951210                                                 │
    │ P691        │ xx0155549                                               │
    │ P7214       │ 63597                                                   │
    │ P1343       │ Q67311526                                               │
    │ P7859       │ lccn-no2007102838                                       │
    │ P1580       │ a1392541                                                │
    │ P2031       │ 1988                                                    │
    │ P5033       │ 63637                                                   │
    │ P1207       │ n2019020135                                             │
    │ P166        │ Q989439                                                 │
    │ P5905       │ 4040-84681                                              │
    │ P5421       │ 164090                                                  │
    ╰─────────────┴─────────────────────────────────────────────────────────╯

If we'd already known Kyle's Wikidata identifier, we could have done

    › wikidata get Q359604

and gotten the same results.

##### Traversal

We can also traverse properties. Let's say we wanted to see that stupid royal baby's paternal lineage:

    › wikidata traverse "Prince George of Cambridge" father

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
  config.faraday_adapter = :typhoeus # default is patron
  # provide the following methods as easy accessors for
  # item.entities_for_property_id(:mother)
  config.property_presets = {
      mother:   "P25",
      father:   "P22",
      children: "P40",
      doctoral_advisor: "P184"
    }
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
