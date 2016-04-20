module DataDotGov
  module Objects
    DEFAULT_ALIASES = {
      'COUNTYNM' => 'county_name',
      'STABBR' => 'state',
      'WEBADDR' => 'web_address',
      'LONGITUD' => 'longitude',
      'LATITUDE' => 'latitude',
      'ZIP' => 'zip_code'
    }

    class Base
      def initialize(attributes = {}, aliases = {})
        aliases = DEFAULT_ALIASES.merge(aliases)

        @_search_column = aliases[self.class.default_search_column]

        attributes.each do |key, value|
          # https://github.com/ohler55/oj#options
          key = aliases[key] if aliases.key?(key)
          instance_variable_set(:"@#{key}", process_value(value))
        end
      end

      def self.default_search_column
        'NAME'
      end

      def search_column
        @_search_column
      end

      def search_column_value
        __send__(search_column)
      end

      def method_missing(*args)
        name = args.shift
        value = instance_variable_get("@#{name}")
        return value unless value.nil?
        instance_variable_get("@#{name.upcase}")
      end

      private

      def process_value(value)
        case value
        when "2"
          false
        when "1"
          true
        else
          value
        end
      end
    end
  end
end
