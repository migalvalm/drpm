# The main screen: games on the left, the selected one's details on the right (or the New project form, or
# command output), key hints or the `:` command bar along the bottom.
class MainScene
  attr_dr
  attr_reader :next_scene

  def initialize session, select = nil
    @session = session
    @games, @edits = Projects.scan
    @index = (select && @games.index(select)) || 0
    @info = {}
    @opened = Kernel.tick_count
    @mode = :details
    selected!
  end

  def selected
    @games[@index]
  end

  # Remembers when the selection changed (the readout types in again) and where the slide bar heads.
  def selected!
    @since = Kernel.tick_count
    @slide_target = GameList.row_y(@index, GameList.offset(@index, @games.size))
    @slide_y ||= @slide_target
  end

  def info name
    @info[name] ||= { meta: Meta.for(name), git: GitInfo.for(name), edited: @edits[name] }
  end

  def tick
    input
    @slide_y += (@slide_target - @slide_y) * 0.35
    draw
  end

  # Keys go to whichever is open: the command bar, the form, the output, or the list.
  def input
    return bar_input if @bar
    return form_input if @mode == :form
    return @mode = :details if @mode == :output && keys[:escape]

    list_keys
    mouse_input
  end

  # Controls.down for this tick (read once, several methods ask).
  def keys
    @keys = Controls.down(inputs) unless @keys_at == Kernel.tick_count
    @keys_at = Kernel.tick_count
    @keys
  end

  def list_keys
    kd = inputs.keyboard.key_down
    move((keys[:down] ? 1 : 0) - (keys[:up] ? 1 : 0))
    return open_bar if inputs.text.include?(':')

    act :play if kd.p || keys[:enter]
    act :tests if kd.t
    act :open if kd.o
    act :new if kd.n
    act :settings if kd.s
    toggle_sound if kd.m
  end

  def move step
    return if step.zero?

    @index = (@index + step).clamp(0, @games.size)   # games.size = the + NEW PROJECT button
    Blip.play audio, :move
    @mode = :details
    selected!
  end

  def mouse_input
    return unless inputs.mouse.click

    hit = GameList.hit(inputs.mouse, @games.size, GameList.offset(@index, @games.size))
    return move(hit - @index) if hit
    return open_form if inputs.mouse.inside_rect?(GameList::BUTTON)
    return act(:settings) if inputs.mouse.inside_rect?(Chrome.settings_rect(@session))

    action = Details.action_at(inputs.mouse)
    act action if action
  end

  # What a key, a click or a command asks for. On the + NEW PROJECT button, Enter / P start the form.
  def act action, name = selected
    return open_form if name.nil? && action == :play

    case action
    when :play then play name
    when :tests then go_tests name
    when :open then open name
    when :new then open_form
    when :settings then go_settings
    end
  end

  def play name
    return note("no game called #{name}") unless @games.include?(name)

    Shell.run Shell.play(name)
    Blip.play audio, :select
    note "#{Theme::PLAY} started #{name}"
  end

  def open name
    return note("no game called #{name}") unless @games.include?(name)

    Shell.run Shell.open(name)
    note "#{Theme::FOLDER} opened #{name}/"
  end

  def go_tests name, file = nil
    return note("no game called #{name}") unless @games.include?(name)

    Blip.play audio, :select
    @next_scene = TestsScene.new(@session, name, file)
  end

  def go_settings
    Blip.play audio, :select
    @next_scene = SettingsScene.new(@session, selected)
  end

  def open_form
    @form = NewForm.new(Templates.list)
    @mode = :form
    @since = Kernel.tick_count
    Blip.play audio, :select
  end

  def toggle_sound
    Blip.muted = !Blip.muted
    Settings.save
    Blip.play audio, :select
  end

  def note text
    @note = [text, Kernel.tick_count]
  end

  def form_input
    result = @form.update(Clipboard.typed(inputs), inputs.keyboard.key_down)
    return close_form if result == :cancel

    create(*result.drop(1)) if result.is_a?(Array)
  end

  def close_form
    @mode = :details
    Blip.play audio, :back
    selected!
  end

  def create folder, title, template
    out = Shell.run Shell.create(folder, title, template)
    return @form&.fail(out.split("\n").first) unless out.include?('CREATED')

    @next_scene = MainScene.new(@session, folder)
    @next_scene.note "#{Theme::CHECK} created #{folder} from #{template.split('/').last}"
    Blip.play audio, :pass
  end

  def open_bar
    @bar = CommandBar.new
    Blip.play audio, :select
  end

  def bar_input
    result = @bar.update(Clipboard.typed(inputs), inputs.keyboard.key_down, @games)
    return unless result

    @bar = nil
    return Blip.play(audio, :back) if result == :close

    run_command result[1]
  end

  # Runs a `:` command line.
  def run_command line
    command = Command.parse(line)
    args = command[:args]
    case command[:name]
    when :play, :open then act command[:name], args[0] || selected
    when :test then go_tests args[0] || selected, args[1]
    when :new then command_new args
    when :git then show_git args[0]
    when :help then output 'HELP', Command::HELP
    when :settings then go_settings
    when :theme then command_theme args[0]
    when :quit then GTK.request_quit
    when :unknown then note "unknown command: #{args[0]} · try :help"
    end
  end

  def command_new args
    return open_form unless args[0]

    problem = Projects.problem(args[0], Projects.taken)
    return note(problem) if problem

    create args[0], args[1] || Projects.title_for(args[0]), Templates.list.first[:path]
  end

  def command_theme name
    return note("themes: #{Theme::ORDER.join(', ')}") unless name && Theme::PALETTES[name.to_sym]

    Theme.apply name.to_sym
    Settings.save
    note "theme: #{name}"
  end

  def show_git what
    return note('no game selected') unless selected

    text = what == 'log' ? Shell.run(Shell.git_log(selected, 16)) : Shell.run(Shell.git_status(selected, true))
    output "GIT #{(what || 'status').upcase} · #{selected}", text.split("\n")
  end

  def output title, lines
    @output = [title, lines]
    @mode = :output
    @since = Kernel.tick_count
  end
end
