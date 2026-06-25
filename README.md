# git-author-report

```
               _                                       _
            _ ( )_                                    ( )_
       __  (_)| ,_)    _ __   __   _ _      _    _ __ | ,_)
     /'_ `\| || |     ( '__)/'__`\( '_`\  /'_`\ ( '__)| |
    ( (_) || || |_    | |  (  ___/| (_) )( (_) )| |   | |_
    `\__  |(_)`\__)   (_)  `\____)| ,__/'`\___/'(_)   `\__)
    ( )_) |                       | |
     \___/'                       (_)
```

> One command, `git report`, tells you who wrote the code in any Git repository.

[![CI](https://github.com/wteuber/git-author-report/actions/workflows/ci.yml/badge.svg)](https://github.com/wteuber/git-author-report/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/git-author-report.svg)](https://rubygems.org/gems/git-author-report)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-2.6%20--%204.0%2B-CC342D.svg)](.ruby-version)

`git-author-report` analyzes a repository and prints a per-author breakdown of how much
code each contributor wrote: surviving lines, lifetime additions and deletions,
commit counts, and files touched, all in a clean ASCII table. It runs on whatever
Ruby is already on your machine (including the stock macOS system Ruby), needs no
Bundler, and has no runtime gem dependencies, so it never touches your global
gems.

```
+-----------------+-----+---------+-------+------+------+
| Name            | LOC | Commits | files | +LOC | -LOC |
+-----------------+-----+---------+-------+------+------+
| John Doe        | 258 |      15 |    12 |  390 |  123 |
| Jane Smith      |  87 |       8 |     5 |  125 |   38 |
+-----------------+-----+---------+-------+------+------+
```

## Table of Contents

- [Why git-author-report?](#why-git-author-report)
- [Quick Start](#quick-start)
- [Understanding the Output](#understanding-the-output)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [How It Works](#how-it-works)
- [Compatibility](#compatibility)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Uninstallation](#uninstallation)
- [License](#license)

## Why git-author-report?

`git shortlog` tells you who committed and how often, but commit counts are a
poor proxy for contribution. `git-author-report` answers the questions that actually
matter:

- **Who owns the code that exists today?** The `LOC` column counts the lines each
  author wrote that still survive in the current tree (via `git blame`), not just
  what they once added.
- **Who has done the most work over time?** The `+LOC` / `-LOC` columns sum every
  line added and removed across the project's history.
- **How is effort spread across the team?** Commits and files-touched fill in the
  rest, all in one table with zero configuration.

## Quick Start

```bash
gem install git-author-report   # also registers a global `git report` alias

cd /path/to/any/repo
git report                      # print the contributor table
git report --version            # print the version and exit
```

`git report` takes no other arguments; it always reports on the repository in
the current directory. Nothing else needs installing, since `git-author-report` has no
runtime gem dependencies and runs straight off the stock system Ruby.

## Understanding the Output

Each row is one contributor (authors with multiple email addresses but the same
name are merged into a single row). The columns:

| Column      | Meaning                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------------ |
| **Name**    | Author name, deduplicated across email addresses.                                                |
| **LOC**     | Lines **currently in the codebase** attributed to this author by `git blame -w` (surviving work).|
| **Commits** | Number of non-merge commits authored.                                                            |
| **files**   | Distinct files in the current tree that contain at least one line by this author.                |
| **+LOC**    | Total lines this author **added** over the entire history (`git log --numstat`, merges excluded).|
| **-LOC**    | Total lines this author **deleted** over the entire history.                                     |

> 💡 **LOC vs. +LOC:** `LOC` measures what *remains* today; `+LOC` measures
> everything ever *written*. A contributor whose code was later refactored away
> can have a high `+LOC` but a low `LOC`.

Rows are sorted by surviving `LOC` (descending), and contributors with no
measurable contribution are omitted. Untracked and uncommitted files are
ignored, so the report reflects committed history only.

## Features

- 📊 Per-author commit, line, and file statistics in one table
- 🧬 Distinguishes surviving code (`LOC`) from lifetime additions/deletions (`+LOC`/`-LOC`)
- 🔀 Merges contributors who used multiple email addresses
- 🚀 Parallel processing (plain Ruby threads) for fast analysis of large repositories
- 🌐 Global `git report` command that works in any repository
- 🧰 Zero runtime dependencies: pure Ruby standard library, nothing to install
- 💎 Runs on Ruby 2.6 through 4.0+, including the stock macOS system Ruby

## Requirements

- Git (any recent version)
- Ruby 2.6 or higher (the macOS system Ruby is fine)
- RubyGems (bundled with Ruby)

## Installation

### Install as a gem (recommended)

```bash
gem install git-author-report
```

Installing the gem also registers a global Git alias so you can run `git report`
from any repository on your machine. (Because the executable is named
`git-report`, Git also resolves `git report` natively once the gem's bin
directory is on your `PATH`.)

### From a clone

```bash
git clone https://github.com/wteuber/git-author-report.git
cd git-author-report
./bin/git_add_alias_report
```

This registers the same global `git report` alias without installing the gem.

### Manual Installation

If you'd rather wire up the alias yourself:

```bash
git config --global alias.report "!exec \"/path/to/git-author-report/bin/git-report\""
```

### Dependencies

None at runtime. `git-author-report` uses only the Ruby standard library, with
parallelism built on plain `Thread` (see [`lib/git/parallel.rb`](lib/git/parallel.rb)),
so there is no gem to install, no Bundler, and no version conflicts. It runs
directly on whatever Ruby is on your `PATH`, including the stock macOS system
Ruby.

## How It Works

1. **Git analysis.** Gathers contributor data with `git shortlog` (commits),
   `git blame -w` (surviving lines and files), and `git log --numstat` (lifetime
   additions/deletions).
2. **Parallel processing.** Uses plain Ruby threads to fan blame and log work
   out across files and authors, keeping large repositories fast. The git
   subprocesses are I/O-bound and release the GVL, so threads give real
   concurrency without any gem.
3. **Author deduplication.** Merges authors who committed under the same name
   with different email addresses into a single row.
4. **No runtime dependencies.** Relies only on the Ruby standard library, so it
   runs on whatever Ruby is on your `PATH` with nothing to install.

## Compatibility

`git-author-report` is designed to run anywhere Git and Ruby already exist:

- ✅ Ruby **2.6 (support floor) through 4.0+**, all verified in CI
- ✅ Runs on the stock macOS system Ruby, so end users need no Ruby install
- ✅ Works with system Ruby or version managers (rbenv, rvm, chruby)
- ✅ No runtime gems to install, so no permission or version conflicts

The Ruby version floor is enforced by RuboCop (`TargetRubyVersion: 2.6`) and a CI
matrix that runs against 2.6, a recent 3.x, and the latest Ruby (4.0). The
`.ruby-version` file (`4.0.4`) only selects a comfortable Ruby for local
development; it does **not** narrow the supported range.

## Troubleshooting

**Permission errors installing gems.** `git-author-report` has no runtime
dependencies, so the only gem involved is `git-author-report` itself. If `gem install`
needs elevated permissions, install into your user gem dir
(`gem install --user-install git-author-report`) or use a version manager.

**Ruby version issues.** The `.ruby-version` file selects Ruby 4.0.4 for local
development, but the tool supports any Ruby from 2.6 up and does not use Bundler
at runtime, so Bundler version conflicts cannot affect it.

**"Not a git repository".** Run `git report` from inside a Git working tree;
the tool reports on the repository in the current directory.

## Development

### Project Structure

```
git-author-report/
├── bin/
│   ├── git-report              # Main executable
│   ├── git_add_alias_report    # Registers the `git report` alias
│   └── git_remove_alias_report # Removes the `git report` alias
├── ext/git_report/
│   ├── extconf.rb              # Install-time hook that adds the alias
│   └── Makefile                # No-op (keeps RubyGems happy)
├── lib/
│   ├── git_report.rb           # Entry point (loads the Git:: classes)
│   ├── version.rb              # Gem version (reads VERSION)
│   ├── rubygems_plugin.rb      # Removes the alias on `gem uninstall`
│   └── git/
│       ├── author.rb           # Author statistics class
│       ├── parallel.rb         # Thread-based parallel map/each helpers
│       └── report.rb           # Report generation class
├── test/                       # minitest suite (smoke + unit tests)
├── git-author-report.gemspec   # Gem specification
├── VERSION                     # Single source of truth for the version
├── Rakefile                    # `rake` runs tests + RuboCop
├── .github/workflows/
│   └── ci.yml                  # CI: tests (Ruby 2.6 + 3.4 + 4.0) and RuboCop
├── .rubocop.yml                # Lint config; enforces the Ruby 2.6 syntax floor
├── Gemfile                     # Declares the Ruby floor (dev deps only)
├── .ruby-version               # Ruby for local development (does not narrow support)
└── README.md                   # This file
```

### Running Tests

The minitest suite drives the real executable against throwaway Git
repositories. It uses only minitest (a Ruby default gem):

```bash
ruby test/smoke_test.rb   # the end-to-end smoke test
# or run everything plus RuboCop:
bundle install
bundle exec rake
```

CI runs the suite on Ruby 2.6, 3.4, and 4.0, plus RuboCop for 2.6 compatibility.

### Contributing

Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your change and keep the tests green (`bundle exec rake`)
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Uninstallation

If you installed the gem:

```bash
gem uninstall git-author-report   # also removes the global `git report` alias
```

If you installed from a clone:

```bash
cd /path/to/git-author-report
./bin/git_remove_alias_report
```

## License

Released under the [MIT License](LICENSE).
