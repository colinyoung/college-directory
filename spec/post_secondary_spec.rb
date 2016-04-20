require 'spec_helper'

describe 'PostSecondary searches' do
  RESOURCE = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING

  it 'returns aliases for colleges' do
    client = DataDotGov::Client.new(RESOURCE)
    VCR.use_cassette('post_secondary__aliases') do
      results = client.search('gadsden')
      college = results.first
      expect(college.institution_name).to eq 'Gadsden State Community College'
      expect(college.other_names).to eq ['GSCC', 'Gadsden State', 'Gadsden Community College']
      expect(college.aliases).to eq ['GSCC', 'Gadsden State', 'Gadsden Community College']
    end
  end

  it 'parses true/false' do
    client = DataDotGov::Client.new(RESOURCE)
    VCR.use_cassette('post_secondary__parses_true_false') do
      harvard = client.search('harvard').first
      spelman = client.search('spelman').first
      iowa_state = client.find('Iowa State University')
      expect(harvard.historically_black).to eq false
      expect(spelman.historically_black).to eq true
      expect(harvard.land_grant).to eq false
      expect(iowa_state.land_grant).to eq true
    end
  end

  it 'can use starts_with for better matches' do
    client = DataDotGov::Client.new(RESOURCE)
    VCR.use_cassette('post_secondary__starts_with') do
      results = client.starts_with('iowa', 50)
      expect(results.size).to eq 9

      all_start_with_iowa = results.map(&:name).all? { |result| result.index('Iowa') == 0 }
      expect(all_start_with_iowa).to eq true

      results = client.starts_with('Iowa State')
      expect(results.size).to eq 1
      expect(results.first.name).to eq 'Iowa State University'
    end
  end

  it 'can use contains for better matches' do
    client = DataDotGov::Client.new(RESOURCE)
    VCR.use_cassette('post_secondary__contains') do
      results = client.contains('Iowa', 50)
      expect(results.size).to eq 19

      all_contain_iowa = results.map(&:name).all? { |result| result.include?('Iowa') }
      expect(all_contain_iowa).to eq true
    end
  end
end
