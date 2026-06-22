# git_report

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

R> A single command — `git report` — that tells you who wrote the code in any Git repository.

[![CI](https://github.com/wteuber/git_report/actions/workflows/ci.yml/badge.svg)](https://github.com/wteuber/git_report/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-2.6%20–%203.4%2B-CC342D.svg)](.ruby-version)

`git_report` analyzes a repository and prints a per-author breakdown of how much
code each contributor wrote — surviving lines, lifetime additions and deletions,
commit counts, and files touched — as a clean ASCII table. It runs on whatever
Ruby is already on your machine (including the stock macOS system Ruby), needs no
Bundler, and installs its one dependency into an isolated local directory so it
never touches your global gems.

```
+-----------------+-----+---------+-------+------+------+
| Name            | LOC | Commits | files | +LOC | -LOC |
+-----------------+-----+---------+-------+------+------+
| John Doe        | 258 |      15 |    12 |  390 |  123 |
| Jane Smith      |  87 |       8 |     5 |  125 |   38 |
+-----------------+-----+---------+-------+------+------+
```

## Table of Contents

- [Why git_report?](#why-git_report)
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

## Why git_report?

`git shortlog` tells you who committed and how often, but commit counts are a
poor proxy for contribution. `git_report` answers the questions that actually
matter:

- **Who owns the code that exists today?** The `LOC` column counts the lines each
  author wrote that still survive in the current tree (via `git blame`), not just
  what they once added.
- **Who has done the most work over time?** The `+LOC` / `-LOC` columns sum every
  line added and removed across the project's history.
- **How is effort spread across the team?** Commits and files-touched round out
  the picture — in one table, with zero configuration.

## Quick Start

```bash
git clone https://github.com/wteuber/git_report.git
cd git_report
./bin/install          # registers a global `git report` alias

cd /path/to/any/repo
git report             # print the contributor table
```

There is nothing to install — `git_report` has no gem dependencies and runs
straight off the stock system Ruby.

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
- 🧰 Zero dependencies — pure Ruby standard library, nothing to install
- 💎 Runs on Ruby 2.6 through 3.4+, including the stock macOS system Ruby

## Requirements

- Git (any recent version)
- Ruby 2.6 or higher (the macOS system Ruby is fine)
- RubyGems (bundled with Ruby)

## Installation

### Quick Install (recommended)

```bash
git clone https://github.com/wteuber/git_report.git
cd git_report
./bin/install
```

This registers a global Git alias so you can run `git report` from any
repository on your machine.

### Manual Installation

If you'd rather wire up the alias yourself:

```bash
git config --global alias.report "!sh -c \"/path/to/git_report/bin/git_report\""
```

### Dependencies

None. `git_report` uses only the Ruby standard library — parallelism is built on
plain `Thread` (see [`lib/git/parallel.rb`](lib/git/parallel.rb)) — so there is
no gem to install, no Bundler, and no version conflicts. It runs directly on
whatever Ruby is on your `PATH`, including the stock macOS system Ruby.

## How It Works

1. **Git analysis** — gathers contributor data with `git shortlog` (commits),
   `git blame -w` (surviving lines and files), and `git log --numstat` (lifetime
   additions/deletions).
2. **Parallel processing** — uses plain Ruby threads to fan blame and log work
   out across files and authors, keeping large repositories fast. The git
   subprocesses are I/O-bound and release the GVL, so threads give real
   concurrency without any gem.
3. **Author deduplication** — merges authors who committed under the same name
   with different email addresses into a single row.
4. **No dependencies** — relies only on the Ruby standard library, so it runs on
   whatever Ruby is on your `PATH` with nothing to install.

## Compatibility

`git_report` is designed to run anywhere Git and Ruby already exist:

- ✅ Ruby **2.6 (support floor) through 3.4+**, both verified in CI
- ✅ Runs on the stock macOS system Ruby — end users need no Ruby install
- ✅ Works with system Ruby or version managers (rbenv, rvm, chruby)
- ✅ No gems to install, so no permission or version conflicts

The Ruby version floor is enforced by RuboCop (`TargetRubyVersion: 2.6`) and a CI
matrix that runs against both 2.6 and a recent Ruby. The `.ruby-version` file
(`3.4.9`) only selects a comfortable Ruby for local development — it does **not**
narrow the supported range.

## Troubleshooting

**Permission errors installing gems** — not applicable: `git_report` installs no
gems. It runs entirely on the Ruby standard library.

**Ruby version issues** — the `.ruby-version` file selects Ruby 3.4.9 for local
development, but the tool supports any Ruby from 2.6 up and does not use Bundler
at runtime, so Bundler version conflicts cannot affect it.

**"Not a git repository"** — run `git report` from inside a Git working tree;
the tool reports on the repository in the current directory.

## Development

### Project Structure

```
git_report/
├── bin/
│   ├── git_report    # Main executable
│   ├── install       # Installation script
│   └── uninstall     # Uninstallation script
├── lib/
│   ├── git_report.rb # Entry point (loads the Git:: classes)
│   └── git/
│       ├── author.rb   # Author statistics class
│       ├── parallel.rb # Thread-based parallel map/each helpers
│       └── report.rb   # Report generation class
├── test/
│   └── smoke_test.rb # End-to-end smoke test
├── .github/workflows/
│   └── ci.yml        # CI: smoke test (Ruby 2.6 + 3.4) and RuboCop
├── .rubocop.yml      # Lint config; enforces the Ruby 2.6 syntax floor
├── Gemfile           # Declares the Ruby floor (no gem dependencies)
├── .ruby-version     # Ruby for local development (does not narrow support)
└── README.md         # This file
```

### Running Tests

An end-to-end smoke test drives the real executable against a throwaway Git
repository. It uses only minitest (a Ruby default gem), so it needs no setup:

```bash
ruby test/smoke_test.rb
```

CI runs this on both Ruby 2.6 and 3.4, plus RuboCop for 2.6 compatibility.

### Contributing

Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your change and keep the smoke test green (`ruby test/smoke_test.rb`)
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Uninstallation

```bash
cd /path/to/git_report
./bin/uninstall
```

This removes the global Git alias; you can then delete the `git_report`
directory.

## License

Released under the [MIT License](LICENSE).

## Acknowledgments

- Original ASCII art logo design
- Built with Ruby and the power of Git
- Thanks to all contributors

## Links

- **Repository**: https://github.com/wteuber/git_report
- **Issues**: https://github.com/wteuber/git_report/issues
- **Pull Requests**: https://github.com/wteuber/git_report/pulls
</content>
</invoke>
