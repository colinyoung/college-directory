require 'yaml'
require 'uri'
require 'open-uri'
require 'oj'
require 'byebug'

module DataDotGov
  class Client
    DEFAULTS = YAML.load_file(File.dirname(__FILE__) + '/../../config/defaults.yml')
    SEARCH_ACTION_PATH = '/action/datastore_search'

    def initialize(options = {})
      options = stringify_hash(options)

      if options.key?('link')
        options['resource_id'] = options['link'].split('/').last
      end

      options['type'] ||= DataDotGov::Objects::Base

      @options = DEFAULTS.merge(stringify_hash(options))
    end

    def search(value, offset = 0, limit = @options['limit'])
      preflight!

      params = {
        q: value,
        resource_id: resource_id,
        offset: offset,
        limit: limit
      }
      response = parse_response get_form_data(params)

      if block_given?
        yield response
      else
        response
      end
    end

    def starts_with(value, limit = 20)
      search(value, 0, limit) do |results|
        results.select { |result| result.search_column_value.downcase.index(value.downcase) == 0 }
      end
    end

    def contains(value, limit = 20)
      search(value, 0, limit) do |results|
        results.select { |result| result.search_column_value.downcase.include?(value.downcase) }
      end
    end

    def find(*args)
      preflight!

      fail ArgumentError if args.empty?

      if args.size > 1
        key = args[0]
        value = args[1]
      else
        value = args[0]
      end

      column_name = resource_class.default_search_column || 'INSTNM'
      json = {
        resource_id: resource_id,
        q: '',
        limit: 1,
        offset: 0,
        filters: { column_name => [value] }
      }

      results = parse_response(post_json(json))
      results.first
    end

    def endpoint
      @options['endpoint']
    end

    def resource_id
      @options['resource_id']
    end

    def resource_class
      @options['type']
    end

    private

    def parse_response(response)
      payload = Oj.load(response)
      result = payload['result']
      return unless result

      type = @options['type']
      result['records'].map { |record| type.new(record) }
    end

    def preflight!
      missing_key!('endpoint') unless endpoint
      missing_key!('resource_id') unless resource_id
    end

    def missing_key!(key)
      fail ArgumentError.new("Required key '#{key}' not defined in #{self.class.name}.new().")
    end

    def stringify_hash(hash)
      Hash[hash.map { |k, v| [k.to_s, v] }]
    end

    def get_form_data(params)
      query = URI.encode_www_form(params)
      uri = URI.parse(endpoint + SEARCH_ACTION_PATH + '?' + query)
      uri.read
    end

    def post_json(json)
      uri = URI.parse(endpoint + SEARCH_ACTION_PATH)
      post = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      post.body = Oj.dump(stringify_hash(json))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(post).body
    end
  end
end
