require 'pmap'
require 'singleton'
require 'set'
require 'active_support/core_ext/string/multibyte'

# LOL
module Git
  Dir[File.dirname(__FILE__) + '/git/**/*.rb'].each(&method(:require))
end
