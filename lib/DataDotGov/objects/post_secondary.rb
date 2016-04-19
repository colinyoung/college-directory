module DataDotGov
  module Objects
    class PostSecondary < Base
      def initialize(attributes = {}, aliases = {})
        super(
          attributes,
          # Aliases
          'INSTNM' =>  'institution_name',
          'CHFTITLE' => 'chairman_title',
          'CHFNM' => 'chairman_name',
          'ADMINURL' => 'admin_url',
          'FAIDURL' => 'financial_aid_url',
          'GENTELE' => 'telephone',
          'LANDGRNT' => 'land_grant'
        )
      end
    end
  end
end
