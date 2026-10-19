module Projects
  def self.parse listing
    listing.split("\n")
           .map { 
            |path| path.delete_prefix("#{Shell::PROJECTS}/").split('/').first 
           }.sort
  end

  def self.scan
    parse Shell.run("ls -d #{Shell::PROJECTS}/*/app/main.rb 2>/dev/null")
  end

  # A game's test files, sorted, from `ls` of its tests folder.
  def self.parse_tests listing
    listing.split("\n").select { |file| file.end_with?('_test.rb') }.sort
  end

  def self.tests name
    parse_tests Shell.run("ls #{Shell::PROJECTS}/#{name}/tests 2>/dev/null")
  end

  def self.duplicated name
    "#{name} already exists" if Projects.taken.include?(name)
  end

  def self.taken
    Shell.run("ls #{Shell::PROJECTS}").split("\n")
  end

  # A title from a folder name: my_game -> My Game.
  def self.title_for name
    name.tr('_-', '  ').split(' ').map(&:capitalize).join(' ')
  end
end