module Git
  # Minimal parallel helpers built on the Ruby standard library, replacing the
  # former `pmap` gem. The work these drive is I/O-bound -- every block shells
  # out to git -- so threads give real concurrency even under MRI's GVL: a
  # subprocess spawned by backticks runs outside the lock while other threads
  # proceed. Keeping this in-tree is what lets git-report run on stock Ruby
  # with no gems to install.
  module Parallel
    # Upper bound on worker threads, and therefore on how many git subprocesses
    # run at once. This cap is the whole point: a repository with thousands of
    # authors must NOT spawn a thread (and a `git log`) per author -- that would
    # swamp the machine. 64 matches the historical default of the pmap gem this
    # replaced, so throughput on large repositories is unchanged.
    MAX_THREADS = 64

    module_function

    # Like Enumerable#map, but runs the block for each element across a bounded
    # pool of threads and returns the results in the original order.
    def pmap(enum, &block)
      results = []
      mutex = Mutex.new
      process(enum) do |item, index|
        value = block.call(item)
        mutex.synchronize { results[index] = value }
      end
      results
    end

    # Like Enumerable#each, but runs the block for each element across a bounded
    # pool of threads. Returns the original enumerable once all work is done.
    def peach(enum, &block)
      process(enum) { |item, _index| block.call(item) }
      enum
    end

    # Drains every [item, index] pair through at most MAX_THREADS workers. All
    # jobs are enqueued up front, so each worker simply pops until the queue is
    # empty and then exits -- no poison pills needed. Joining via Thread#value
    # propagates the first exception raised in any worker to the caller.
    def process(enum)
      items = enum.to_a
      queue = Queue.new
      items.each_with_index { |item, index| queue << [item, index] }

      worker_count = [items.size, MAX_THREADS].min
      workers = Array.new(worker_count) do
        Thread.new do
          # We re-raise from Thread#value below, so silence Ruby's automatic
          # "terminated with exception" dump to stderr -- it would otherwise
          # print the same error twice.
          Thread.current.report_on_exception = false
          loop do
            begin
              item, index = queue.pop(true)
            rescue ThreadError
              break # queue drained
            end
            yield item, index
          end
        end
      end
      workers.each(&:value)
    end
    private_class_method :process
  end
end
