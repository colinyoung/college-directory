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
        attributes.each do |key, value|
          # https://github.com/ohler55/oj#options
          key = aliases[key] if aliases[key]
          instance_variable_set(:"@#{key}", value)
        end
      end

      def method_missing(*args)
        name = args.shift
        instance_variable_get("@#{name.to_s}") || instance_variable_get("@#{name.upcase.to_s}")
      end
    end
  end
end
