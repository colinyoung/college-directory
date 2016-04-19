# DataDotGov

[![Circle CI](https://circleci.com/gh/moneythink/data.gov.svg?style=svg)](https://circleci.com/gh/moneythink/data.gov) [![Code Climate](https://codeclimate.com/repos/5716a309ec824e00920037de/badges/f9f006b036c05bbbc3cd/gpa.svg)](https://codeclimate.com/repos/5716a309ec824e00920037de/feed) [![Test Coverage](https://codeclimate.com/repos/5716a309ec824e00920037de/badges/f9f006b036c05bbbc3cd/coverage.svg)](https://codeclimate.com/repos/5716a309ec824e00920037de/coverage)

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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec DataDotGov` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/DataDotGov/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
