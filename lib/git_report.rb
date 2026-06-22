require 'pmap'
require 'set'

# Git module - contains classes for analyzing git repository statistics
module Git
  # Auto-load all classes in the git subdirectory (sorted for deterministic
  # load order across platforms)
  Dir[File.join(File.dirname(__FILE__), 'git', '**', '*.rb')].sort.each(&method(:require))
end
