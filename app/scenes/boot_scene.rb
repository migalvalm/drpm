# The boot sequence: DRPM checks what it has (SDK, games, templates, git) line by line, then opens the main
# screen, or Setup when the folders aren't chosen yet. Any key or click skips it.
class BootScene
  attr_dr
  attr_reader :next_scene

  STEP = 9      # ticks between lines
  HOLD = 50     # ticks on SYSTEM READY before moving on

  def initialize session
    @session = session
    @start = Kernel.tick_count
    @ready = Paths.ready?
    @lines = checks
  end

  # [what, result, ok?] per line.
  def checks
    git = Shell.run('git --version 2>/dev/null').include?('git version')
    folders = @ready ? found : [['sdk', 'not set · setup is next', false]]
    folders + [['git', git ? 'OK' : 'missing', git], ['sound', Blip.muted ? 'off' : 'on', true]]
  end

  def found
    sdk = @session.sdk
    templates = Templates.list.size
    [['sdk', "#{sdk[:version]} #{sdk[:tier].downcase}", sdk[:version] != '?'],
     ['projects', "#{Projects.scan.first.size} found", true],
     ['templates', "#{templates - 1} found (+ blank game)", true]]
  end

  def tick
    age = Kernel.tick_count - @start
    draw age
    Blip.play audio, :type if age < @lines.size * STEP && age % 3 == 0
    skip = inputs.keyboard.key_down.truthy_keys.any? || inputs.mouse.click
    finish if skip || age > @lines.size * STEP + HOLD
  end

  def finish
    @next_scene = @ready ? MainScene.new(@session) : SetupScene.new(@session)
  end

  def draw age
    out = [Hud.text(80, 600, Hud.reveal('DRPM', @start, 0.5), size: 64, color: Theme.accent, font: Theme::EXTRABOLD),
           Hud.text(80, 548, "dragonruby project manager  //  v#{version}", size: 18, color: Theme.dim, font: Theme::LIGHT)]
    @lines.each_with_index { |line, i| out.concat(boot_line(line, i, age)) if age >= i * STEP }
    out << ready(age) if age >= @lines.size * STEP
    outputs.primitives << out
  end

  # DRPM's own version, from its metadata (the one place it is set; builds are named after it too).
  def version
    @version ||= Meta.parse(GTK.read_file('metadata/game_metadata.txt') || '')[:version] || '?'
  end

  def boot_line line, index, age
    what, result, ok = line
    start = @start + index * STEP
    y = 470 - index * 40
    dots = Hud.readout(what, '', 26).rstrip
    out = [Hud.text(80, y, Hud.reveal("> #{dots}", start, 4), size: 22, color: Theme.text)]
    out << Hud.text(96 + Hud.width("> #{'.' * 27}", 22), y, result, size: 22, color: ok ? Theme.ok : Theme.fail, font: Theme::BOLD) if age > index * STEP + 6
    out
  end

  def ready age
    caret = age.div(15).even? ? '█' : ''
    text = @ready ? '> SYSTEM READY' : '> SETUP REQUIRED'
    Hud.text(80, 220, "#{text}#{caret}", size: 26, color: Theme.select, font: Theme::BOLD)
  end
end
