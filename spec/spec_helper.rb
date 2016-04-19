if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'DataDotGov'

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.default_cassette_options = { record: :none }

  # For uploading coverage reports
  config.ignore_hosts 'codeclimate.com'
end
