# frozen_string_literal: true

require_relative 'test_helper'

# Unit tests for the in-tree thread-pool helpers that replaced the pmap gem.
class ParallelTest < Minitest::Test
  def test_pmap_returns_results_in_input_order
    assert_equal [1, 4, 9, 16, 25],
                 Git::Parallel.pmap([1, 2, 3, 4, 5]) { |n| n * n }
  end

  def test_pmap_on_empty_collection_does_no_work
    ran = false
    assert_equal([], Git::Parallel.pmap([]) { ran = true })
    refute ran
  end

  def test_peach_runs_the_block_for_every_element_and_returns_the_enum
    seen = Queue.new
    enum = %w[a b c]

    result = Git::Parallel.peach(enum) { |x| seen << x }

    assert_same enum, result
    assert_equal %w[a b c], drain(seen).sort
  end

  def test_peach_on_empty_collection_does_no_work
    ran = false
    Git::Parallel.peach([]) { ran = true }
    refute ran
  end

  def test_uses_multiple_threads_concurrently
    ids = Queue.new

    Git::Parallel.peach([1, 2, 3, 4]) do
      ids << Thread.current.object_id
      sleep 0.05
    end

    assert_operator drain(ids).uniq.size, :>, 1
  end

  def test_never_exceeds_the_thread_cap
    count = Git::Parallel::MAX_THREADS + 25
    ids = Queue.new

    Git::Parallel.pmap((1..count).to_a) do |n|
      ids << Thread.current.object_id
      n
    end

    assert_operator drain(ids).uniq.size, :<=, Git::Parallel::MAX_THREADS
  end

  def test_propagates_the_first_worker_exception
    error = assert_raises(RuntimeError) do
      Git::Parallel.peach([1, 2, 3, 4]) { raise 'kaboom' }
    end

    assert_equal 'kaboom', error.message
  end

  private

  def drain(queue)
    items = []
    items << queue.pop until queue.empty?
    items
  end
end
