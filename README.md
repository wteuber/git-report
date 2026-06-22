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

A Ruby-based Git statistics tool that analyzes and displays commit statistics for all contributors in a repository, including lines of code, commit counts, and file changes.

## Features

- 📊 Display commit statistics per author
- 📈 Show added/deleted lines of code
- 🚀 Parallel processing for faster analysis
- 🔧 Works with any Git repository
- 🌐 Global `git report` command
- 🔄 Automatic dependency management
- 💎 Compatible with Ruby 2.6 through 3.4+

## Usage

Simply navigate to any Git repository and run:

```bash
git report
```

The tool will analyze the repository and display statistics for all contributors.

## Example Output

```
+-----------------+-----+---------+-------+------+------+
| Name            | LOC | Commits | files | +LOC | -LOC |
+-----------------+-----+---------+-------+------+------+
| John Doe        | 258 |      15 |    12 |  390 |  123 |
| Jane Smith      |  87 |       8 |     5 |  125 |   38 |
+-----------------+-----+---------+-------+------+------+
```

## Requirements

- Git (any recent version)
- Ruby 2.6 or higher
- RubyGems (included with Ruby)

## Installation

### Quick Install

1. Clone the repository:
   ```bash
   git clone https://github.com/wteuber/git_report.git
   cd git_report
   ```

2. Run the install script:
   ```bash
   ./bin/install
   ```

This will set up a global Git alias, allowing you to use `git report` in any repository.

### Manual Installation

If you prefer manual installation:

1. Clone the repository to your preferred location
2. Add the git alias manually:
   ```bash
   git config --global alias.report "!sh -c \"/path/to/git_report/bin/git_report\""
   ```

### Dependencies

The tool's only runtime dependency is the `pmap` gem; everything else it needs
is in the Ruby standard library. It installs `pmap` automatically into a
project-local `vendor/` directory on first run (no Bundler, no global install).
If you prefer to install it manually:

```bash
gem install pmap
```

## How It Works

1. **Git Analysis**: Uses `git log` and `git shortlog` to gather commit data
2. **Parallel Processing**: Utilizes the `pmap` gem for efficient processing of large repositories
3. **Isolated Dependency Management**: Installs its single gem into a project-local `vendor/` directory with an isolated `GEM_HOME`/`GEM_PATH`, so it never clashes with the gems of whatever Ruby is on your `PATH`
4. **Author Deduplication**: Intelligently merges statistics for authors with multiple email addresses

## Compatibility

git_report is designed to work across different Ruby versions and environments:

- ✅ Ruby 2.6 (the support floor) through 3.4+, verified in CI on both
- ✅ Runs on the stock macOS system Ruby — no Ruby install required for end users
- ✅ Works with system Ruby or version managers (rbenv, rvm, chruby)
- ✅ Installs its gem locally in an isolated `vendor/` dir to avoid permission and version conflicts

The Ruby version floor is enforced by RuboCop (`TargetRubyVersion: 2.6`) and a CI
matrix that runs against both 2.6 and a recent Ruby. The `.ruby-version` file
(`3.4.9`) only selects a comfortable Ruby for local development — it does not
narrow the supported range.

## Troubleshooting

### Permission Errors

If you encounter permission errors when installing gems, the tool will automatically install them to a local vendor directory.

### Ruby Version Issues

The `.ruby-version` file selects Ruby 3.4.9 for local development, but the tool
supports any Ruby from 2.6 up. It does not use Bundler at runtime, so Bundler
version conflicts cannot affect it.

### Missing Dependencies

If you see errors about missing gems, remove the local gem cache and let the tool
reinstall on the next run:
```bash
cd /path/to/git_report
rm -rf vendor
```

## Development

### Project Structure

```
git_report/
├── bin/
│   ├── git_report    # Main executable
│   ├── install       # Installation script
│   └── uninstall     # Uninstallation script
├── lib/
│   ├── git_report.rb # Main library file
│   └── git/
│       ├── author.rb # Author statistics class
│       └── report.rb # Report generation class
├── test/
│   └── smoke_test.rb # End-to-end smoke test
├── .github/workflows/
│   └── ci.yml        # CI: smoke test (Ruby 2.6 + 3.4) and RuboCop
├── .rubocop.yml     # Lint config; enforces the Ruby 2.6 syntax floor
├── Gemfile          # Ruby dependencies (just pmap)
├── .ruby-version    # Ruby for local development (does not narrow support)
└── README.md        # This file
```

### Running Tests

An end-to-end smoke test drives the real executable against a throwaway git
repository. It uses only minitest (a Ruby default gem), so it needs no setup:

```bash
ruby test/smoke_test.rb
```

CI runs this on both Ruby 2.6 and 3.4, plus RuboCop for 2.6 compatibility.

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Uninstallation

To remove git_report:

```bash
cd /path/to/git_report
./bin/uninstall
```

This will remove the global Git alias. You can then delete the git_report directory.

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Original ASCII art logo design
- Built with Ruby and the power of Git
- Special thanks to all contributors

## Links

- **Repository**: https://github.com/wteuber/git_report
- **Issues**: https://github.com/wteuber/git_report/issues
- **Pull Requests**: https://github.com/wteuber/git_report/pulls
