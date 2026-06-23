# frozen_string_literal: true

Gem.pre_uninstall do |uninstaller|
  bin_dir = uninstaller.spec.bin_dir
  git_remove_alias_report = File.join(bin_dir, 'git_remove_alias_report')
  puts `#{git_remove_alias_report}`
end
