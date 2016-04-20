module DataDotGov
  module Objects
    class PostSecondary < Base
      def initialize(attributes = {}, _aliases = {})
        aliases = attributes['IALIAS']
        if aliases
          attributes['other_names'] = aliases.split('|').map(&:strip)
        end

        super(
          attributes,
          # Aliases
          'INSTNM' =>  'institution_name',
          'CHFTITLE' => 'chairman_title',
          'CHFNM' => 'chairman_name',
          'ADMINURL' => 'admin_url',
          'FAIDURL' => 'financial_aid_url',
          'GENTELE' => 'phone_number',
          'FAXTELE' => 'fax_number',
          'LANDGRNT' => 'land_grant'
        )
      end

      def self.default_search_column
        'INSTNM'
      end

      def aliases
        @other_names
      end

      def historically_black
        @HBCU
      end

      def name
        @institution_name
      end
    end
  end
end
