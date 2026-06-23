# frozen_string_literal: true

require 'rake/testtask'

# Default task runs the test suite and RuboCop
task default: %i[test rubocop]

desc 'Run the test suite'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*test*.rb']
  t.verbose = true
end

desc 'Run RuboCop (Ruby 2.6 compatibility check)'
task :rubocop do
  sh 'bundle exec rubocop'
end
