# keys of report are the authors, the values contains the report data:
#  * commits, +LOC, -LOC, LOC,
module Git
  #
  class Author
    # name: String - the name of the author
    # emails: Set<String> - a list of email addresses
    # commits: Fixnum - number of commits by this author
    # loc_added: Fixnum  - number of lines this author added over time
    # loc_deleted: Fixnum  - number of lines this author deleted over time
    # loc: Fixnum - number of lines in the current codebase this author added
    # files: Fixnum - number of files
    attr_reader :name, :emails, :commits, :loc_added, :loc_deleted, :loc, :files

    #
    def initialize(name:, emails: '', commits: 0)
      @name = name
      @emails = Set.new Array(emails)
      @commits = commits.to_i
      @loc = 0
      @loc_added = 0
      @loc_deleted = 0
      @files = 0
    end

    def merge(other)
      return unless mergable?(other)
      @emails.merge other.emails
      @commits += other.commits
      self
    end

    def mergable?(other)
      name == other.name
    end

    def retreive_loc_stats
      emails.pmap do |email|
        numstat = `git log --author="#{email}" \
          --pretty=tformat: --numstat --no-merges`
        loc = numstat.split(/\n/).map do |numstat_line|
          numstat_line.scan(/\A(.*)\t(.*)\t/)[0].map(&:to_i)
        end

        added, deleted = loc.transpose.map do |add_del_loc|
          add_del_loc.inject(&:+)
        end
        puts email if $OUT
        @loc_added += added if added
        @loc_deleted += deleted if deleted
      end
    end

    def loc=(loc)
      @loc = loc.to_i
    end

    def files=(files)
      @files = files.to_i
    end
  end
end
