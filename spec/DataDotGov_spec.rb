require 'spec_helper'

describe DataDotGov do
  it 'has a version number' do
    expect(DataDotGov::VERSION).not_to be nil
  end

  TEST_RESOURCE_ID = '6d2a0324-5964-44c3-97be-061c0eb5fcc9'

  it 'can initialize with constant' do
    resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
    client = DataDotGov::Client.new(resource)
    expect(client.resource_id).to eq '38625c3d-5388-4c16-a30f-d105432553a4'
    expect(client.endpoint).to eq 'https://inventory.data.gov/api/3'
  end

  it 'can initialize with resource_id' do
    client = DataDotGov::Client.new(resource_id: TEST_RESOURCE_ID)
    expect(client.resource_id).to eq TEST_RESOURCE_ID
  end

  it 'can query by search param with resource' do
    resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
    client = DataDotGov::Client.new(resource)
    VCR.use_cassette('L21') do
      results = client.search('depaul')
      expect(results.size).to eq(1)
      expect(results.first.institution_name).to eq 'DePaul University'
    end
  end

  it 'can query by search param with resource_id' do
    client = DataDotGov::Client.new(resource_id: TEST_RESOURCE_ID)
    VCR.use_cassette('L31') do
      results = client.search('Child Care Provider/Assistant')
      expect(results.size).to eq(100)
      expect(results.last.program_title).to eq 'Child Care Provider/Assistant'
      expect(results.last.award_level).to eq 'Associate\'s degree'
    end
  end
end
