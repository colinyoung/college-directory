require 'yaml'
require 'uri'
require 'open-uri'
require 'oj'
require 'active_support/notifications'
require 'active_support/cache'

module DataDotGov
  class Client
    DEFAULTS = YAML.load_file(File.dirname(__FILE__) + '/../../config/defaults.yml')
    SEARCH_ACTION_PATH = '/action/datastore_search'

    def initialize(*args)
      options = {}
      args.each { |h| options.merge!(stringify_hash(h)) }

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
      cache_key = params.hash
      return fetch(cache_key) if cached?(cache_key)

      query = URI.encode_www_form(params)
      uri = URI.parse(endpoint + SEARCH_ACTION_PATH + '?' + query)
      response = uri.read

      cache(cache_key, response) if cache_enabled?
      response
    end

    def post_json(json)
      uri = URI.parse(endpoint + SEARCH_ACTION_PATH)
      post = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      body = Oj.dump(stringify_hash(json))

      cache_key = body.hash
      return fetch(cache_key) if cached?(cache_key)

      post.body = body
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(post).body

      cache(cache_key, response) if cache_enabled?
      response
    end

    def fetch(key)
      puts "[Data.gov] Cache hit #{key}"
      cache_store.fetch(key)
    end

    def cache(key, value)
      puts "[Data.gov] Cache miss #{key}, writing to cache"
      cache_store.write(key, value) # One month expiration
    end

    def cached?(key)
      cache_store.exist?(key)
    end

    def cache_enabled?
      if @options.key?('cache')
        return @options['cache']
      elsif !@options['cache_store'].nil?
        return true
      elsif !@options['cache_options'].nil?
        return true
      end
    end

    def cache_store
      @cache_store ||= begin
        options = {
          compress: true,
          expires_in: 2592000 # Expire all items in one month
        }
        options.merge!(@options['cache_options'] || {})

        puts "[Data.gov] Using #{cache_store_class} for caching"

        if @options.key?('cache_servers')
          cache_store_class.new(cache_servers, options)
        else
          cache_store_class.new(options)
        end
      end
    end

    def cache_store_class
      case @options['cache_store']
      when :memory
        ActiveSupport::Cache::MemoryStore
      when :file
        ActiveSupport::Cache::FileStore
      when :memcache, :memcached
        ActiveSupport::Cache::MemCacheStore
      else
        ActiveSupport::Cache::MemoryStore
      end
    end
  end
end
