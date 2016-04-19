require 'yaml'
require 'uri'
require 'open-uri'
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

      params = {
        q: value,
        resource_id: resource_id
      }
      query = URI.encode_www_form(params)
      uri = URI.parse(endpoint + '/action/datastore_search' + '?' + query)
      parse_response uri.read
    end

    def endpoint
      @options['endpoint']
    end

    def resource_id
      @options['resource_id']
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
  end
end
