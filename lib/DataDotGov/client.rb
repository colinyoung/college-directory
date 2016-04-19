require 'yaml'
require 'net/http'
require 'uri'
require 'oj'

module DataDotGov
  class Client
    DEFAULTS = YAML.load_file(File.dirname(__FILE__) + '/../../config/defaults.yml')

    def initialize(options = {})
      options = stringify_hash(options)

      if options.key?('link')
        options['resource_id'] = options['link'].split('/').last
      end

      options['type'] ||= DataDotGov::Objects::Base

      @options = DEFAULTS.merge(stringify_hash(options))
    end

    def search(value, _offset = 0, _limit = @options['limit'])
      preflight!

      uri = URI.parse(endpoint + '/action/datastore_search')
      params = {
        q: value,
        resource_id: resource_id
      }
      uri.query = URI.encode_www_form(params)
      parse_response Net::HTTP.get_response(uri)
      # post = Net::HTTP::Post.new(uri.request_uri)
      # post.body = JSON.generate(
      #   q: value,
      #   resource_id: resource_id,
      #   offset: offset,
      #   limit: limit
      # )
      # p post.body
    end

    def endpoint
      @options['endpoint']
    end

    def resource_id
      @options['resource_id']
    end

    private

    def parse_response(response)
      payload = Oj.load(response.body)
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
  end
end
