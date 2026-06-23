# frozen_string_literal: true

require 'mkmf'

find_executable('bash')
find_executable('git')
find_executable('make')

# Trick Rubygems into thinking the generated artifact was compiled
compile = File.join(Dir.pwd, "git_report.#{RbConfig::CONFIG['DLEXT']}")
File.write(compile, '')

# Install "git report"
puts `../../bin/git_add_alias_report`

# Trick Rubygems into thinking the Makefile was executed
$makefile_created = true
