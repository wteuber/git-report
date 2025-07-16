require 'pmap'
require 'set'
require 'active_support/core_ext/string/multibyte'

# Git module - contains classes for analyzing git repository statistics
module Git
  # Auto-load all classes in the git subdirectory
  Dir[File.dirname(__FILE__) + '/git/**/*.rb'].each(&method(:require))
end
