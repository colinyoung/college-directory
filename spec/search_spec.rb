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
    VCR.use_cassette('search__resource') do
      results = client.search('depaul')
      expect(results.size).to eq(1)
      expect(results.first.institution_name).to eq 'DePaul University'
    end
  end

  it 'can query by search param with resource_id' do
    client = DataDotGov::Client.new(resource_id: TEST_RESOURCE_ID)
    VCR.use_cassette('search__resource_id') do
      results = client.search('Child Care Provider/Assistant')
      expect(results.size).to eq(20)
      expect(results.last.program_title).to eq 'Child Care Provider/Assistant'
      expect(results.last.award_level).to eq 'Associate\'s degree'
    end
  end

  it 'can cache a response in-memory to search' do
    resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
    client = DataDotGov::Client.new(resource, cache: true)

    results1 = nil
    VCR.use_cassette('search__to_be_cached') do
      results1 = client.search('depaul')
    end
    expect(results1.size).to eq(1)

    results2 = nil
    expect { results2 = client.search('depaul') }.not_to raise_error
    expect(results2).to eq results1
  end

  it 'can cache a response in-memory to find' do
    resource = DataDotGov::Resources::Ed::PostSecondary::DIRECTORY_LISTING
    client = DataDotGov::Client.new(resource, cache: true)

    result1 = nil
    VCR.use_cassette('find__to_be_cached') do
      result1 = client.find('DePaul University')
    end
    expect(result1).not_to be_nil

    result2 = nil
    expect { result2 = client.find('DePaul University') }.not_to raise_error
    expect(result2).to eq result1
  end

  it 'can configure alternate cache stores' do
    client = DataDotGov::Client.new(cache: :memcached)
    expect(client.send(:cache_store)).to be_a ActiveSupport::Cache::MemCacheStore

    client = DataDotGov::Client.new(cache: :file)
    expect(client.send(:cache_store)).to be_a ActiveSupport::Cache::FileStore
  end

  it 'can configure custom cache options' do
    client = DataDotGov::Client.new(cache_options: {expires_in: 86400})
    options = client.instance_variable_get(:@options)['cache_options']
    expect(options).to eq(expires_in: 86400)
  end

  it 'will raise errors if initialized incorrectly' do
    client = DataDotGov::Client.new
    expect { client.search('asdf') }.to raise_error(ArgumentError)
  end

  it 'can inspect constants' do
    expect(DataDotGov::Resources::Ed.inspect).to eq '[:PostSecondary]'
    expect(DataDotGov::Resources::Ed::PostSecondary.inspect).to eq '[:DIRECTORY_LISTING, :CIP_2000, :AWARDS_DEGREES_CONFERRED_BY_PROGRAM, :AWARDS_DEGREES_CONFERRED_ADV, :EDUCATIONAL_OFFERINGS__ATHLETIC_ASSOCIATIONS, :FINAID_AND_NET_PRICE]'
  end
end
