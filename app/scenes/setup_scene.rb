# Setup: where the SDK, the projects and the templates are. Each field is checked as you go (Enter) and Tab
# completes folder names like a shell. SAVE keeps them (Settings) and opens the main screen. Shown on first run,
# and from Settings > FOLDERS (where Esc cancels).
class SetupScene
  attr_dr
  attr_reader :next_scene

  ROWS = [[:sdk, 'SDK FOLDER', 'the unzipped dragonruby-<platform> folder, with ./dragonruby in it'],
          [:projects, 'PROJECTS FOLDER', 'where your games are: one folder per game, each with app/main.rb'],
          [:templates, 'TEMPLATES FOLDER', "optional: folders New project can copy (the SDK's mygame is always there)"]].freeze
  FIELD_W = 900

  def initialize session, editing = false
    @session, @editing = session, editing
    @home = Shell.home
    @fields = ROWS.map { |key, _, _| [key, Field.new(start_value(key), 240, nil, FIELD_W)] }.to_h
    @checks = {}
    @focus = 0
    @opened = Kernel.tick_count
    ROWS.each { |key, _, _| check key }
  end

  # What a field starts with: the current setting, or a guess (the SDK DRPM runs from, and projects/ and
  # templates/ beside it, when they exist).
  def start_value key
    current = Paths.send(key).to_s
    return current unless current.empty?

    pwd = Shell.run('pwd').strip
    return (Paths.check(pwd) == 'sdk' ? pwd : '') if key == :sdk

    guess = "#{pwd.split('/')[0...-2].join('/')}/#{key}"
    Paths.check(guess).empty? ? '' : guess
  end

  def key_at index
    ROWS[index][0]
  end

  # The field's path checked: [problem or nil, what was found].
  def check key
    path = Paths.expand(@fields[key].text, @home)
    state = path.empty? ? '' : Paths.check(path)
    @checks[key] = [Paths.problem(key, path, state), found(key, path, state)]
  end

  def found key, path, state
    return '' if path.empty? || state.empty?
    return "#{Theme::CHECK} dragonruby found" if key == :sdk

    count = Shell.run("ls -d #{Paths.q path}/*/#{key == :projects ? 'app/main.rb' : ''} 2>/dev/null").split("\n").size
    "#{Theme::CHECK} #{count} #{key == :projects ? 'games' : 'templates'}"
  end

  def ok?
    ROWS.all? { |key, _, _| @checks[key][0].nil? }
  end

  def tick
    kd = inputs.keyboard.key_down
    return cancel if kd.escape && @editing

    @focus < ROWS.size ? field_keys(kd) : save_keys(kd)
    mouse
    draw
  end

  def field_keys kd
    key = key_at(@focus)
    field = @fields[key]
    field.update(inputs.text, kd)
    field.text = Paths.complete(Paths.expand(field.text, @home), Paths.listing(Paths.expand(field.text, @home))) if kd.tab
    move(-1) if kd.up
    enter key if kd.enter || kd.kp_enter || kd.down
  end

  def enter key
    check key
    return Blip.play(audio, :back) if @checks[key][0]

    move 1
  end

  def save_keys kd
    move(-1) if kd.up
    save if kd.enter || kd.kp_enter
  end

  def move step
    @focus = (@focus + step).clamp(0, ROWS.size)
    Blip.play audio, :move
  end

  def mouse
    return unless inputs.mouse.click

    row = (0...ROWS.size).find { |i| inputs.mouse.inside_rect?(x: 48, y: row_y(i) - 50, w: 1180, h: 90) }
    @focus = row if row
    save if inputs.mouse.inside_rect?(save_rect)
  end

  def save
    ROWS.each { |key, _, _| check key }
    return Blip.play(audio, :back) unless ok?

    ROWS.each { |key, _, _| Paths.send("#{key}=", Paths.expand(@fields[key].text, @home)) }
    Settings.save
    @session.reload_sdk
    Blip.play audio, :pass
    @next_scene = MainScene.new(@session)
  end

  def cancel
    Blip.play audio, :back
    @next_scene = SettingsScene.new(@session)
  end

  def row_y index
    470 - index * 120
  end

  def save_rect
    { x: 48, y: 96, w: 220, h: 48 }
  end
end
