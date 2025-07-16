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

The tool will automatically install required gems on first run. If you prefer to install them manually:

```bash
cd /path/to/git_report
bundle install
```

Or without bundler:
```bash
gem install pmap activesupport bigdecimal
```

## How It Works

1. **Git Analysis**: Uses `git log` and `git shortlog` to gather commit data
2. **Parallel Processing**: Utilizes the `pmap` gem for efficient processing of large repositories
3. **Smart Dependency Management**: Automatically handles Ruby version differences and gem installation
4. **Author Deduplication**: Intelligently merges statistics for authors with multiple email addresses

## Compatibility

git_report is designed to work across different Ruby versions and environments:

- ✅ Ruby 2.6 - 3.4+
- ✅ Works with system Ruby or version managers (rbenv, rvm, chruby)
- ✅ Handles bundler version conflicts automatically
- ✅ Installs gems locally when needed to avoid permission issues

## Troubleshooting

### Permission Errors

If you encounter permission errors when installing gems, the tool will automatically install them to a local vendor directory.

### Ruby Version Issues

The tool includes a `.ruby-version` file specifying Ruby 2.6.10, but it works with any Ruby version 2.6 or higher. If you have issues with bundler compatibility (especially with Ruby 3.4+), the tool will automatically fall back to direct gem installation.

### Missing Dependencies

If you see errors about missing gems, run from the git_report directory:
```bash
cd /path/to/git_report
bundle install --path vendor/bundle
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
├── Gemfile          # Ruby dependencies
├── .ruby-version    # Ruby version specification
└── README.md        # This file
```

### Running Tests

Currently, this project doesn't include tests. Contributions to add a test suite are welcome!

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
