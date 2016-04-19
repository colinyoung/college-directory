require 'DataDotGov/version'
relpath = __FILE__.chomp('.rb') + '/objects/*'
Dir[relpath].each { |f| require f }

require 'DataDotGov/client'
require 'DataDotGov/resources'

module DataDotGov
end
