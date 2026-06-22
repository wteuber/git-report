# frozen_string_literal: true

# End-to-end smoke test. It drives the real bin/git_report launcher -- including
# its gem-vendoring step -- against a throwaway git repository, so it exercises
# exactly what an end user runs. minitest ships with Ruby (a default gem), so
# this adds no dependency and runs on the 2.6 support floor as well as modern
# Rubies.
require 'minitest/autorun'
require 'open3'
require 'tmpdir'

class SmokeTest < Minitest::Test
  BIN = File.expand_path('../bin/git_report', __dir__)

  def test_reports_authors_for_a_repo
    Dir.mktmpdir do |dir|
      git(dir, 'init', '-q')
      commit(dir, 'a.txt', "line one\nline two\n",
             name: 'Ada Lovelace', email: 'ada@example.com')
      commit(dir, 'b.txt', "only line\n",
             name: 'Alan Turing', email: 'alan@example.com')

      out, status = Open3.capture2(BIN, chdir: dir)

      assert status.success?, "git_report exited non-zero:\n#{out}"
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

  private

  def git(dir, *args)
    out, status = Open3.capture2e('git', '-C', dir, *args)
    raise "git #{args.join(' ')} failed:\n#{out}" unless status.success?
  end

  def commit(dir, file, content, name:, email:)
    File.write(File.join(dir, file), content)
    git(dir, 'add', file)
    git(dir, '-c', "user.name=#{name}", '-c', "user.email=#{email}",
        'commit', '-q', '-m', "add #{file}")
  end
end
