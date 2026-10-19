# The boot sequence: the launcher checks what it has (SDK, games, templates, git) line by line, then opens
# the main screen. Any key or click skips it.
class BootScene
  attr_dr
  attr_reader :next_scene

  STEP = 9      # ticks between lines
  HOLD = 50     # ticks on SYSTEM READY before moving on

  def initialize session
    @session = session
    @start = Kernel.tick_count
    @lines = checks.map { |what, result, ok| [Hud.readout(what, '', 26).rstrip, result, ok] }
  end

  # [what, result, ok?] per line.
  def checks
    games = Projects.scan.first
    templates = Templates.list
    git = Shell.run('git --version 2>/dev/null').include?('git version')
    [['sdk', "#{@session.sdk[:version]} #{@session.sdk[:tier].downcase}", @session.sdk[:version] != '?'],
     ['projects/', "#{games.size} found", true],
     ['templates/', "#{templates.size} found (#{templates.size - 1} yours + sdk mygame)", true],
     ['git', git ? 'OK' : 'missing', git],
     ['sound', Blip.muted ? 'off' : 'on', true]]
  end

  def tick
    age = Kernel.tick_count - @start
    draw age
    Blip.play audio, :type if age < @lines.size * STEP && age % 3 == 0
    skip = inputs.keyboard.key_down.truthy_keys.any? || inputs.mouse.click
    @next_scene = MainScene.new(@session) if skip || age > @lines.size * STEP + HOLD
  end

  def draw age
    out = [Hud.text(80, 600, Hud.reveal('DRAGONRUBY LAUNCHER', @start, 1.5), size: 44, color: Theme::ACCENT, font: Theme::EXTRABOLD),
           Hud.text(80, 556, 'v0.2  //  game launcher for dragonruby gtk', size: 18, color: Theme::DIM, font: Theme::LIGHT)]
    @lines.each_with_index { |line, i| out.concat(boot_line(line, i, age)) if age >= i * STEP }
    out << ready(age) if age >= @lines.size * STEP
    outputs.primitives << out
  end

  def boot_line line, index, age
    what, result, ok = line
    start = @start + index * STEP
    y = 480 - index * 40
    shown = Hud.reveal("> #{what}", start, 4)
    out = [Hud.text(80, y, shown, size: 22, color: Theme::TEXT)]
    out << Hud.text(96 + Hud.width("> #{'.' * 27}", 22), y, result, size: 22, color: ok ? Theme::OK : Theme::FAIL, font: Theme::BOLD) if age > index * STEP + 6
    out
  end

  def ready age
    caret = age.div(15).even? ? '█' : ''
    Hud.text(80, 230, "> SYSTEM READY#{caret}", size: 26, color: Theme::SELECT, font: Theme::BOLD)
  end
end
