# The `:` command line: parsing and Tab completion. Plain module, no args.
module Command
  NAMES = %w[play test open new git help quit].freeze
  GIT   = %w[status log].freeze
  HELP  = [':play <game>          start a game',
           ':test <game> [file]   run all its tests, or one file',
           ':open <game>          open its folder',
           ':new <folder> [title] new game from the template',
           ':git status | log     for the selected game',
           ':help  :quit',
           'keys  up/down select  p play  t tests  o open  n new  m sound  : command'].freeze

  # { name: :play, args: [...] }; title after `new <folder>` keeps its spaces and loses its quotes.
  def self.parse line
    word, rest = line.strip.split(' ', 2)
    return { name: :none, args: [] } unless word
    return { name: :unknown, args: [word] } unless NAMES.include?(word)
    return { name: :new, args: new_args(rest.to_s) } if word == 'new'

    { name: word.to_sym, args: rest.to_s.split(' ') }
  end

  def self.new_args rest
    folder, title = rest.strip.split(' ', 2)
    [folder, title&.delete('"')].compact
  end

  # The line with its last word completed from commands, games or git subcommands; unchanged if nothing matches.
  def self.complete line, games
    words = line.split(' ', -1)
    words = [''] if words.empty?
    choices = words.size == 1 ? NAMES : choices_after(words.first, games)
    match = choices.find { |c| c.start_with?(words.last) }
    return line unless match

    (words[0...-1] + [match]).join(' ') + (words.size == 1 ? ' ' : '')
  end

  def self.choices_after command, games
    command == 'git' ? GIT : games
  end
end
