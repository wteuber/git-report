# frozen_string_literal: true

module Git
  # Report carries the gem version, read from the VERSION file at the repo root.
  class Report
    VERSION_FILE = File.expand_path('../VERSION', __dir__)
    VERSION = File.exist?(VERSION_FILE) ? File.read(VERSION_FILE).strip : 'unknown'
  end
end
