require 'DataDotGov/version'

relpath = __FILE__.chomp('.rb') + '/objects/*'
Dir[relpath].each { |f| require f unless f.match(/base\.rb\z/) }

require 'DataDotGov/client'
require 'DataDotGov/resources'

module DataDotGov
end
