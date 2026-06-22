source 'https://rubygems.org'

# Supported Ruby floor: 2.6 (the stock macOS system Ruby). Any dependency added
# here must keep publishing a version whose required_ruby_version still allows
# 2.6, or the no-install-needed story on macOS breaks.
ruby '>= 2.6.0'

# git_report has no runtime dependencies: everything it needs is in the Ruby
# standard library, so the tool runs on the stock macOS system Ruby without the
# user installing Ruby or any gems. Parallelism uses plain threads (see
# lib/git/parallel.rb). Keep this Gemfile dependency-free.
