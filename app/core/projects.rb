# The games: every folder in the projects folder (Paths.projects) with an app/main.rb, newest edit first.
# When that folder is the SDK itself, its own mygame/ isn't listed.
module Projects
  # What a new game's folder and title may hold: also safe inside Shell.create's sh and sed.
  NAME_CHARS  = 'abcdefghijklmnopqrstuvwxyz0123456789_-'.freeze
  TITLE_CHARS = "#{NAME_CHARS}ABCDEFGHIJKLMNOPQRSTUVWXYZ ".freeze

  # Game names from `ls -d <projects>/*/app/main.rb` (one path per line).
  def self.parse listing, projects = Paths.projects, sdk = Paths.sdk
    names = listing.split("\n").map { |path| name_in path, projects }.sort
    projects == sdk ? names - [Shell::MYGAME] : names
  end

  # { name => newest change time } from Shell.edits output.
  def self.parse_edits listing, projects = Paths.projects
    listing.split("\n").each_with_object({}) do |line, newest|
      time, path = line.split(' ', 2)
      name = name_in path, projects
      newest[name] = [newest[name] || 0, time.to_f].max
    end
  end

  # Names, last edited first; ties and unknowns by name.
  def self.sort names, edits
    names.sort_by { |name| [-(edits[name] || 0), name] }
  end

  def self.name_in path, projects
    path.delete_prefix("#{projects}/").split('/').first
  end

  # [names sorted, { name => newest edit }]
  def self.scan
    edits = parse_edits Shell.run(Shell.edits)
    [sort(parse(Shell.run(Shell.games)), edits), edits]
  end

  # A game's test files, sorted, from `ls` of its tests folder.
  def self.parse_tests listing
    listing.split("\n").select { |file| file.end_with?('_test.rb') }.sort
  end

  def self.tests name
    parse_tests Shell.run(Shell.tests(name))
  end

  # Why a new folder can't take this name (taken = the names already in the projects folder), or nil.
  def self.problem name, taken
    return 'folder name is empty' if name.empty?
    return 'folder name: only a-z, 0-9, _ and -' unless name.each_char.all? { |c| NAME_CHARS.include?(c) }

    "#{name} already exists" if taken.include?(name)
  end

  # A typed title with only TITLE_CHARS kept.
  def self.clean_title title
    title.each_char.select { |c| TITLE_CHARS.include?(c) }.join.strip
  end

  def self.taken
    Shell.run(Shell.folders(Paths.projects)).split("\n").map { |name| name.chomp('/') }
  end

  # A title from a folder name: my_game -> My Game.
  def self.title_for name
    name.tr('_-', '  ').split(' ').map(&:capitalize).join(' ')
  end
end
