# The games: every folder in launcher/projects/ (Shell::PROJECTS) with an app/main.rb, newest edit first.
module Projects
  # Game names from `ls -d ../../projects/*/app/main.rb` (one path per line).
  def self.parse listing
    listing.split("\n").map { |path| name_in path }.sort
  end

  # { name => newest change time } from Shell.edits output.
  def self.parse_edits listing
    listing.split("\n").each_with_object({}) do |line, newest|
      time, path = line.split(' ', 2)
      name = name_in path
      newest[name] = [newest[name] || 0, time.to_f].max
    end
  end

  # Names, last edited first; ties and unknowns by name.
  def self.sort names, edits
    names.sort_by { |name| [-(edits[name] || 0), name] }
  end

  def self.name_in path
    path.delete_prefix("#{Shell::PROJECTS}/").split('/').first
  end

  # [names sorted, { name => newest edit }]
  def self.scan
    edits = parse_edits Shell.run(Shell.edits)
    [sort(parse(Shell.run("ls -d #{Shell::PROJECTS}/*/app/main.rb 2>/dev/null")), edits), edits]
  end

  def self.templates
    Shell.run("ls #{Shell::TEMPLATES} 2>/dev/null").split("\n")
  end

  # A game's test files, sorted, from `ls` of its tests folder.
  def self.parse_tests listing
    listing.split("\n").select { |file| file.end_with?('_test.rb') }.sort
  end

  def self.tests name
    parse_tests Shell.run("ls #{Shell::PROJECTS}/#{name}/tests 2>/dev/null")
  end

  # Why a new folder can't take this name (taken = the names already in launcher/projects/), or nil.
  def self.problem name, taken
    return 'folder name is empty' if name.empty?

    "#{name} already exists" if taken.include?(name)
  end

  def self.taken
    Shell.run("ls #{Shell::PROJECTS}").split("\n")
  end

  # A title from a folder name: my_game -> My Game.
  def self.title_for name
    name.tr('_-', '  ').split(' ').map(&:capitalize).join(' ')
  end
end
