# DataDotGov

This gem can be used to easily search and query the Data.gov CKAN APIs. For example, those located at:

- http://www.ed.gov/developer
- (Not an exhaustive list)

Any resource that can be found on [data.gov](http://www.data.gov/) should be searchable via its `resource_id`, which take a format like `c95fae96-ce4a-459c-a935-ba2a37767ac9`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'DataDotGov'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install DataDotGov

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
