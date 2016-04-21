# DataDotGov

[![Circle CI](https://circleci.com/gh/moneythink/data.gov.svg?style=svg)](https://circleci.com/gh/moneythink/data.gov) [![Code Climate](https://codeclimate.com/github/moneythink/data.gov/badges/gpa.svg)](https://codeclimate.com/github/moneythink/data.gov) [![Test Coverage](https://codeclimate.com/github/moneythink/data.gov/badges/coverage.svg)](https://codeclimate.com/github/moneythink/data.gov/coverage) [![Issue Count](https://codeclimate.com/github/moneythink/data.gov/badges/issue_count.svg)](https://codeclimate.com/github/moneythink/data.gov)

This gem can be used to easily search and query the Data.gov CKAN APIs. For example, those located at:

- http://www.ed.gov/developer
- (Not an exhaustive list)

Any resource that can be found on [data.gov](http://www.data.gov/) should be searchable via its `resource_id`. These generally adhere to a format like `c95fae96-ce4a-459c-a935-ba2a37767ac9`, and can be found on Inventory pages [(example)](https://inventory.data.gov/dataset/032e19b4-5a90-41dc-83ff-6e4cd234f565/resource/38625c3d-5388-4c16-a30f-d105432553a4) and are found in the final portion of the URL path.

## Installation

```ruby
gem 'DataDotGov', github: 'moneythink/data.gov'
```

## Usage

```ruby
# use predefined resources
resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
client = DataDotGov::Client.new(resource)
client.search('depaul') #=> [#<DataDotGov::Objects::PostSecondary:0x007ff8c5904cf8 @_id=1104, @institution_name="DePaul University", @state="IL", ... ]

# use whatever resource_id you like (obtain from Data.gov):
client = DataDotGov::Client.new(resource_id: '6d2a0324-5964-44c3-97be-061c0eb5fcc9')
results = client.search('Child Care Provider/Assistant')
results.last.program_title # => 'Child Card Provider/Assistant'
results.first.award_level # => 'Associate's degree'

# configure client to cache responses for the same params consecutively in memory
resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
client = DataDotGov::Client.new(resource, cache: true)
result1 = client.find('DePaul University') #=> not from cache
result2 = client.find('DePaul University') #=> from cache
```

## Cache configuration

```ruby
resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
client = DataDotGov::Client.new(resource, cache_options: { expires_in: 86400 }) # Default cache is MemoryStore (which is a bad idea for Rails apps!)
# Other options:
client = DataDotGov::Client.new(resource, cache: :memcache, cache_servers: ['192.168.0.1'])
client = DataDotGov::Client.new(resource, cache: :file, cache_file_path: 'tmp/cache/data.gov-cache')
```

## Client methods

Methods you can use to search with a `DataDotGov::Client` instance:

- [search](#search)
- [contains](#contains)
- [starts_with](#starts_with)
- [find](#find-has-some-caveats)

#### `search`

**Usage:** `search(value, offset = 0, limit = 20)`

**Example:** `search('illinois', 0, 10)`

**Returns:** All items containing the given word _anywhere_ in its data. You may get some VERY tangential matches! For example, if you're searching using the `DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING` item and you search a state school like 'Illinois', you'll get matches that have addresses on Illinois Street, etc. Use methods below for more restrictive results.

**Sample results for `DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING`:** Objects with names of "Colorado School of Mines"‡, "Carl Sandburg College", "Southwestern Illinois College", "Illinois Wesleyan University", "Hair Professionals Academy of Cosmetology", "Illinois State University", "DeVry University-Illinois", "Illinois College of Optometry", "Eastern Illinois University", "Illinois College", etc.

‡ See. I told you. Colorado School of Mines is on 1500 Illinois St in Golden, CO.

#### `contains`

**Usage:** `contains(value, limit = 20)`

**Example:** `contains('pennsylvania', 50)`

**Returns:** Up to 50 results with names containing the word 'pennsylvania' or 'Pennsylvania'. _Note: The limit is the number of results that will be returned; you are likely to get fewer than 50 results as the endpoint will often return matches that belong to the state of Pennsylvania, or in a county called Pennsylvania, or other matches outside of the title. AFAIK, there is no way to fuzzy match on a name field only._

**Sample results for `DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING`:** Objects with names of "Pennsylvania Institute of Health and Technology", "Strayer University-Pennsylvania", "Pennsylvania Institute of Taxidermy Inc", "York College Pennsylvania", "Central Pennsylvania Institute of Science and Technology", "DeVry University-Pennsylvania", etc.

#### `starts_with`

**Usage:** `starts_with(value, limit = 20)`

**Example:** `starts_with('iowa', 50)`

**Returns:** Up to 50 results with names _starting with_ the word 'iowa' or 'Iowa'. _Note: The limit is the number of results that will be returned; you are likely to get fewer than 50 results as the endpoint will often return matches that belong to the state of Iowa, or in a county called Iowa, or other matches outside of the title. Currently, there is no way to fuzzy match on a name field only._

**Sample results for `DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING`:** Objects with names of "Iowa Wesleyan College", "Iowa Western Community College", "Iowa Central Community College", "Iowa Lakes Community College", etc.

#### `find` (has some caveats)

**Usage:** `find(exact_name)`

**Example:** `find('DePaul University')`

**Returns:** An EXACT match for the term.

**Sample results for `DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING`:** DePaul University†

† _Note_: If you search 'depaul university' or 'DePaul', you will get NOTHING. This has to be exact. Another good example is Ohio State University: its official record is 'Ohio State University-Main Campus', so good luck finding that with exact name.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec DataDotGov` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/DataDotGov/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
