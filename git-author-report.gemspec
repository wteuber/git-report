# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name                  = 'git-author-report'
  s.required_ruby_version = '>= 2.6'
  s.version               = Git::Report::VERSION
  s.licenses              = ['MIT']
  s.summary               = 'Per-author contribution report for any git repository'
  s.description           = 'git-author-report is a command line tool, run as `git report`, ' \
                            'that prints a per-author breakdown of code contribution ' \
                            '(surviving LOC, lifetime +/-LOC, commits, files) as an ASCII table.'
  s.authors               = ['Wolfgang Teuber']
  s.email                 = 'knugie@gmx.net'
  s.files                 = Dir['{lib/**/*.rb,bin/*}'] + Dir['ext/git_report/Makefile'] + ['VERSION']
  s.require_paths         = ['lib']
  s.executables           = ['git-report']
  s.extensions            = Dir['ext/git_report/extconf.rb']
  s.homepage              = 'https://github.com/wteuber/git-author-report'
  s.metadata              = { 'source_code_uri' => 'https://github.com/wteuber/git-author-report',
                              'rubygems_mfa_required' => 'true' }
end
