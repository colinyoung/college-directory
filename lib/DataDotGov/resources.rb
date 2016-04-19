module Inspectable
  def inspect
    constants.inspect
  end
end

module DataDotGov
  module Resources
    # Department of Education: ed.gov/developer
    module Ed
      extend Inspectable

      # PostSecondary (Colleges and Universities)
      module PostSecondary
        extend Inspectable

        DIRECTORY_LISTING = {
          link: 'https://inventory.data.gov/dataset/032e19b4-5a90-41dc-83ff-6e4cd234f565/resource/38625c3d-5388-4c16-a30f-d105432553a4',
          type: DataDotGov::Objects::PostSecondary
        }
        CIP_2000 = {
          link: 'https://inventory.data.gov/dataset/b06ca923-ec64-4000-a9e1-86216bb3907d/resource/6fa1786f-ef01-4471-b033-aea7a7169e6c'
        }
        AWARDS_DEGREES_CONFERRED_BY_PROGRAM = {
          link: 'https://inventory.data.gov/dataset/1e63afca-9587-4b72-aa05-a7f597e9305b/resource/6d2a0324-5964-44c3-97be-061c0eb5fcc9'
        }
        AWARDS_DEGREES_CONFERRED_ADV = {
          link: 'https://inventory.data.gov/dataset/c44c10ef-4dff-4f15-a3bb-2847f5d70a59/resource/ec830504-afb7-499e-bb97-406388bc6078'
        }
        EDUCATIONAL_OFFERINGS__ATHLETIC_ASSOCIATIONS = {
          link: 'https://inventory.data.gov/dataset/fb384d70-fff0-4bed-802c-935875500206/resource/8a656436-59e7-4f4d-bd16-a7fd58cfbb60'
        }
        FINAID_AND_NET_PRICE = {
          link: 'https://inventory.data.gov/dataset/d3c1aa87-e6ba-4963-9d8d-43f2417d3925/resource/2384aff0-e30f-4e92-8ea4-1f1127a91912'
        }
      end
    end
  end
end
