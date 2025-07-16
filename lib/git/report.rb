# Git report module for analyzing repository statistics
require 'shellwords'

module Git
  # Report class - generates statistics about git repository contributors
  # Analyzes commits, lines of code, and file changes per author
  class Report
    attr_reader :authors

    NAME = /\A[^(]*\((.*)\s*\d{4}-\d\d-\d\d \d\d:\d\d:\d\d [+-]\d{4}\s+\d+\)/
    COMMITS_NAME_EMAIL = /\A\s*(\d*)\t(.*) <(.*)>/
    HEADER = {
      name:    'Name',
      loc:     'LOC',
      commits: 'Commits',
      files:   'files',
      loc_add: '+LOC',
      loc_del: '-LOC'
    }.freeze

    def initialize
      @authors = []
    end

    def retrieve_stats
      verify_git_repository
      parse_shortlog
      parse_blame
      self
    end
    


    def parse_shortlog
      # First pass: get all authors (including those with only merges)
      `git shortlog -se`.split(/\n/).map do |shortlog_line|
        add shortlog_line, commits: 0
      end

      # Second pass: get actual commit counts (excluding merges)
      `git shortlog -se --no-merges`.split(/\n/).map do |shortlog_line|
        add shortlog_line
      end

      authors.peach(&:retrieve_loc_stats)
    end

    def parse_blame
      ls_files        = `git ls-files`.split(/\n/)
      ignore_files    = `git status --porcelain`.split(/\n/)
      ignore_files.map! { |file| file[3..-1] }
      ls_files -= ignore_files

      file_lists      = ls_files.each_slice((ls_files.count**0.5).ceil).to_a
      names_loc_count = Hash.new(0)
      names_files     = {}

      file_lists.peach do |files|
        files.each do |file|
          escaped_file = Shellwords.escape(file)
          blame = `git blame -w #{escaped_file} 2> /dev/null`
          next if blame.empty?
          blame.unpack('C*').pack('C*').split(/\n/).map do |line|
            name = line.match(NAME)[1].strip.force_encoding('UTF-8')
            names_loc_count[name] += 1
            names_files[name] ||= Set.new
            names_files[name] << file
          end
        end
      end
      names_loc_count.each { |name, loc| find_author(name).loc = loc }
      names_files.each { |name, files| find_author(name).files = files.size }
    end

    def add(line, opts = {})
      shortlog_line = format_shortlog_line(*line.scan(COMMITS_NAME_EMAIL)[0])
      shortlog_line[:commits] = opts[:commits] if opts[:commits]
      candidate = Author.new **shortlog_line
      @authors << candidate unless add_author candidate
    end

    def add_author(candidate)
      merged = false
      @authors.each do |author|
        if author.mergable?(candidate)
          author.merge(candidate)
          merged = true
        end
      end
      merged
    end

    def find_author(name)
      @authors.find { |author| author.name == name }
    end

    def stats
      authors.sort! { |this, other| other.name  <=> this.name }
      authors.sort! { |this, other| other.files <=> this.files }
      authors.sort! { |this, other| other.loc   <=> this.loc }

      name_length =    authors.map { |auth| auth.name.length }.max
      loc_length =     authors.map { |auth| auth.loc.to_s.length }.max
      commits_length = authors.map { |auth| auth.commits.to_s.length }.max
      files_length =   authors.map { |auth| auth.files.to_s.length }.max
      loc_add_length = authors.map { |auth| auth.loc_added.to_s.length }.max
      loc_del_length = authors.map { |auth| auth.loc_deleted.to_s.length }.max

      name_length =    [name_length, HEADER[:name].length].max
      loc_length =     [loc_length, HEADER[:loc].length].max
      commits_length = [commits_length, HEADER[:commits].length].max
      files_length =   [files_length, HEADER[:files].length].max
      loc_add_length = [loc_add_length, HEADER[:loc_add].length].max
      loc_del_length = [loc_del_length, HEADER[:loc_del].length].max

      lines = []
      hr = '+' + '-' * name_length + '--'
      hr += '+' + '-' * loc_length + '--'
      hr += '+' + '-' * commits_length + '--'
      hr += '+' + '-' * files_length + '--'
      hr += '+' + '-' * loc_add_length + '--'
      hr += '+' + '-' * loc_del_length + '--+'

      head =  "| #{HEADER[:name].ljust(name_length)} "
      head += "| #{HEADER[:loc].rjust(loc_length)} "
      head += "| #{HEADER[:commits].rjust(commits_length)} "
      head += "| #{HEADER[:files].rjust(files_length)} "
      head += "| #{HEADER[:loc_add].rjust(loc_add_length)} "
      head += "| #{HEADER[:loc_del].to_s.rjust(loc_del_length)} |"

      lines << hr
      lines << head
      lines << hr
      authors.each do |author|
        # Skip authors with no contributions
        next if [author.loc, author.commits, author.files, author.loc_added,
                 author.loc_deleted].all?(&:zero?)
                 
        line =  "| #{author.name.mb_chars.unicode_normalize.ljust(name_length)} "
        line += "| #{author.loc.to_s.rjust(loc_length)} "
        line += "| #{author.commits.to_s.rjust(commits_length)} "
        line += "| #{author.files.to_s.rjust(files_length)} "
        line += "| #{author.loc_added.to_s.rjust(loc_add_length)} "
        line += "| #{author.loc_deleted.to_s.rjust(loc_del_length)} |"
        lines << line
      end
      lines << hr
      lines
    end

    private

    def verify_git_repository
      unless system('git rev-parse --git-dir > /dev/null 2>&1')
        raise "Not a git repository (or any of the parent directories)"
      end
    end

    def format_shortlog_line(commits, name, email)
      { name: name, emails: email, commits: commits.to_i }
    end
  end
end
