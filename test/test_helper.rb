# frozen_string_literal: true

require 'minitest/autorun'
require 'open3'
require 'tmpdir'

require_relative '../lib/git_report'

# Shared helpers for the test suite: building throwaway git repositories and
# exercising git-report against them, both in-process (so coverage sees the
# library run) and through the real bin/git-report launcher (end-to-end).
module GitFixture
  BIN = File.expand_path('../bin/git-report', __dir__)

  # Run the library directly in this process against +dir+ and return the
  # rendered report as a single string.
  def report_table(dir)
    Dir.chdir(dir) { Git::Report.new.retrieve_stats.stats }.join("\n")
  end

  # Run the real launcher in a subprocess -- the exact thing an end user runs.
  def run_report(dir)
    out, status = Open3.capture2(BIN, chdir: dir)
    assert status.success?, "git-report exited non-zero:\n#{out}"
    out
  end

  def git(dir, *args)
    out, status = Open3.capture2e('git', '-C', dir, *args)
    raise "git #{args.join(' ')} failed:\n#{out}" unless status.success?

    out
  end

  def commit(dir, file, content, name:, email:)
    File.write(File.join(dir, file), content)
    git(dir, 'add', file)
    git(dir, '-c', "user.name=#{name}", '-c', "user.email=#{email}",
        'commit', '-q', '-m', "touch #{file}")
  end

  # Parse the report table into
  # { name => { loc:, commits:, files:, added:, deleted: } }.
  def rows_by_author(report_output)
    report_output.each_line.with_object({}) do |line, rows|
      cells = line.split('|').map(&:strip)
      cells.shift while !cells.empty? && cells.first.empty?
      cells.pop while !cells.empty? && cells.last.empty?
      next unless cells.size == 6 && cells.first != 'Name'
      next unless cells[1].match?(/\A\d+\z/)

      rows[cells[0]] = {
        loc: Integer(cells[1]), commits: Integer(cells[2]),
        files: Integer(cells[3]), added: Integer(cells[4]),
        deleted: Integer(cells[5])
      }
    end
  end

  def loc_by_author(report_output)
    rows_by_author(report_output).transform_values { |row| row.fetch(:loc) }
  end

  # Lines per author straight from `git blame`, mirroring the pipeline the old
  # git-lines-per-author.sh ran: list tracked text files and tally each line's
  # author.
  def blame_line_counts(dir)
    script = <<~'SH'
      git ls-files | \
      while read filename; do file "$filename"; done | \
      grep -E ': .*text' | sed -E -e 's/: .*//' | \
      while read filename; do git blame --line-porcelain "$filename"; done | \
      sed -n 's/^author //p' | \
      sort | uniq -c
    SH
    out, status = Open3.capture2e('sh', '-c', script, chdir: dir)
    raise "blame pipeline failed:\n#{out}" unless status.success?

    out.each_line.with_object({}) do |line, counts|
      next unless (m = line.match(/\A\s*(\d+)\s+(.*\S)\s*\z/))

      counts[m[2]] = Integer(m[1])
    end
  end
end
