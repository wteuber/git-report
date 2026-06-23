# frozen_string_literal: true

require_relative 'test_helper'

# End-to-end smoke tests. They drive the real bin/git-report launcher against
# throwaway repositories, exercising exactly what an end user runs -- including
# that the tool needs no gems installed. minitest ships with Ruby and the tool
# has no dependencies, so this also runs on the 2.6 support floor.
class SmokeTest < Minitest::Test
  include GitFixture

  def test_reports_authors_for_a_repo
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'a.txt', "line one\nline two\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      commit(dir, 'b.txt', "only line\n",
             name: 'Alan Turing', email: 'alan@example.com')

      out = run_report(dir)

      assert_match(/\bName\b/, out)
      assert_match(/\bLOC\b/, out)
      assert_includes out, 'Ada Lovelace'
      assert_includes out, 'Alan Turing'
    end
  end

  def test_errors_outside_a_git_repository
    Dir.mktmpdir do |dir|
      out, status = Open3.capture2e(BIN, chdir: dir)

      refute status.success?, "expected a non-zero exit outside a git repo:\n#{out}"
      assert_match(/not a git repository/i, out)
    end
  end

  # The LOC column must match git's own blame attribution. This used to be a
  # manual check run via git-lines-per-author.sh: that script counted current
  # lines per author straight from `git blame`, and we eyeballed it against the
  # report. Here we run the same blame pipeline as the source of truth and
  # assert git-report's LOC column reproduces it exactly, including a file
  # edited by more than one author.
  def test_loc_column_matches_git_blame_line_counts
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'a.txt', "line one\nline two\nline three\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      commit(dir, 'b.txt', "alan line\n",
             name: 'Alan Turing', email: 'alan@example.com')
      # Ada appends to Alan's file, so b.txt is attributed to both authors.
      commit(dir, 'b.txt', "alan line\nada one\nada two\n",
             name: 'Ada Lovelace', email: 'ada@example.com')

      out = run_report(dir)

      expected = blame_line_counts(dir)
      assert_equal({ 'Ada Lovelace' => 5, 'Alan Turing' => 1 }, expected,
                   'blame pipeline produced an unexpected baseline')
      assert_equal expected, loc_by_author(out)
    end
  end
end
