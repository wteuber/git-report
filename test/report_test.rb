# frozen_string_literal: true

require_relative 'test_helper'

# Drives Git::Report directly (in-process) against throwaway repositories so
# the per-author aggregation -- LOC, commits, files, +LOC/-LOC, author merging,
# and the various skip paths -- is exercised against real git output.
class ReportTest < Minitest::Test
  include GitFixture

  def test_aggregates_loc_commits_files_and_added_deleted_per_author
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'alpha.txt', "a1\na2\na3\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      commit(dir, 'beta.txt', "b1\nb2\n",
             name: 'Alan Turing', email: 'alan@example.com')
      # Same name, different email: the two identities merge into one author.
      commit(dir, 'gamma.txt', "g1\n",
             name: 'Ada Lovelace', email: 'ada@work.com')
      commit(dir, 'delta.txt', "d1\nd2\n",
             name: 'Alan Turing', email: 'alan@example.com')
      # Ada rewrites Alan's second beta line: +1/-1, and that current line is
      # now blamed on Ada.
      commit(dir, 'beta.txt', "b1\nB2 edited by ada\n",
             name: 'Ada Lovelace', email: 'ada@example.com')

      rows = rows_by_author(report_table(dir))

      assert_equal(
        { loc: 5, commits: 3, files: 3, added: 5, deleted: 1 },
        rows.fetch('Ada Lovelace')
      )
      assert_equal(
        { loc: 3, commits: 2, files: 2, added: 4, deleted: 0 },
        rows.fetch('Alan Turing')
      )
    end
  end

  def test_skips_empty_files_and_merge_only_authors
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'real.txt', "x\ny\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      # An empty tracked file: `git blame` emits nothing, exercising the
      # blame-empty skip and contributing no lines.
      commit(dir, 'empty.txt', '',
             name: 'Ada Lovelace', email: 'ada@example.com')

      branch = git(dir, 'rev-parse', '--abbrev-ref', 'HEAD').strip
      git(dir, 'checkout', '-q', '-b', 'feature')
      commit(dir, 'feature.txt', "f1\n",
             name: 'Alan Turing', email: 'alan@example.com')
      git(dir, 'checkout', '-q', branch)
      # Merge authored by someone with no commits of their own: they appear in
      # `shortlog -se HEAD` but contribute zero lines/commits, so they are
      # dropped from the report.
      git(dir, '-c', 'user.name=Merge Bot', '-c', 'user.email=bot@example.com',
          'merge', '--no-ff', '-q', '-m', 'merge feature', 'feature')

      rows = rows_by_author(report_table(dir))

      refute_includes rows.keys, 'Merge Bot'
      assert_equal({ loc: 2, commits: 2, files: 1, added: 2, deleted: 0 },
                   rows.fetch('Ada Lovelace'))
      assert_equal({ loc: 1, commits: 1, files: 1, added: 1, deleted: 0 },
                   rows.fetch('Alan Turing'))
    end
  end

  def test_excludes_modified_and_untracked_files_from_blame
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'one.txt', "1\n2\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      commit(dir, 'two.txt', "3\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      # A dirty tracked file and a brand-new untracked file both show up in
      # `git status --porcelain` and must be excluded from blame entirely.
      File.write(File.join(dir, 'two.txt'), "3\n4\n")
      File.write(File.join(dir, 'untracked.txt'), "u\n")

      ada = rows_by_author(report_table(dir)).fetch('Ada Lovelace')

      # Only one.txt is counted. Were two.txt not excluded, loc would be 3.
      assert_equal 2, ada[:loc]
      assert_equal 1, ada[:files]
    end
  end

  def test_raises_outside_a_git_repository
    Dir.mktmpdir do |dir|
      error = assert_raises(RuntimeError) do
        Dir.chdir(dir) { Git::Report.new.retrieve_stats }
      end

      assert_match(/not a git repository/i, error.message)
    end
  end
end
