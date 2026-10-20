# Settings: the sections on the left (theme, sound, folders), the chosen one on the right. ←/→ (or a click) changes
# theme and sound at once, applied live and saved; Enter on FOLDERS opens Setup. Esc goes back.
class SettingsScene
  attr_dr
  attr_reader :next_scene

  SECTIONS = %w[THEME SOUND FOLDERS].freeze
  X = 452
  Y = 72
  W = 804
  H = 584
  CARD_W = 360
  CARD_H = 200

  def initialize session, back_to = nil
    @session, @back_to = session, back_to
    @index = 0
    @opened = Kernel.tick_count
  end

  def tick
    keys = Controls.down(inputs)
    return back if keys[:escape]

    move((keys[:down] ? 1 : 0) - (keys[:up] ? 1 : 0))
    change((keys[:right] ? 1 : 0) - (keys[:left] ? 1 : 0)) if keys[:left] || keys[:right]
    change(1) if keys[:enter] && @index == 1
    folders if keys[:enter] && @index == 2
    click if inputs.mouse.click
    draw
  end

  def back
    Blip.play audio, :back
    @next_scene = MainScene.new(@session, @back_to)
  end

  def move step
    return if step.zero?

    @index = (@index + step).clamp(0, SECTIONS.size - 1)
    Blip.play audio, :move
  end

  # ←/→ on the focused section: the next/previous theme, or sound on/off.
  def change step
    return if @index == 2

    @index.zero? ? theme(Theme.step(step)) : sound(!Blip.muted)
  end

  def folders
    Blip.play audio, :select
    @next_scene = SetupScene.new(@session, true)
  end

  def theme name
    Theme.apply name
    Settings.save
    Blip.play audio, :select
  end

  def sound mute
    Blip.muted = mute
    Settings.save
    Blip.play audio, :select
  end

  # A click on a section focuses it; on a theme card, picks it; on the sound switch, flips it.
  def click
    hit = GameList.hit(inputs.mouse, SECTIONS.size, 0)
    return move(hit - @index) if hit

    card = Theme::ORDER.find { |name| inputs.mouse.inside_rect?(card_rect(name)) }
    return theme(card) if card && @index.zero?

    sound(!Blip.muted) if @index == 1 && inputs.mouse.inside_rect?(x: X + 28, y: Y + 360, w: 300, h: 90)
    folders if @index == 2 && inputs.mouse.inside_rect?(x: X + 28, y: Y + 160, w: 300, h: 56)
  end

  # Where a palette's card sits: two by two.
  def card_rect name
    i = Theme::ORDER.index(name)
    { x: X + 28 + (i % 2) * (CARD_W + 20), y: Y + 250 - i.div(2) * (CARD_H + 20), w: CARD_W, h: CARD_H }
  end

  def draw
    grow = Hud.ease(@opened, 24)
    out = Chrome.header(@session, 'settings')
    out.concat(GameList.draw(SECTIONS, {}, @index, GameList.row_y(@index, 0), @session, grow, title: 'SETTINGS', dots: false))
    out.concat(Hud.frame(X, Y, W, H, SECTIONS[@index], grow))
    out.concat([themes, sound_pane, folders_pane][@index]) if grow > 0.9
    out.concat(Chrome.keys([['↑↓', 'section'], ['←→', 'change'], ['ENTER', 'folders'], ['ESC', 'back']]))
    outputs.primitives << out
    Fx.draw outputs
  end

  def themes
    out = [Hud.text(X + 28, Y + 528, 'THEME', size: 34, color: Theme.accent, font: Theme::EXTRABOLD),
           Hud.text(X + 28, Y + 484, '←/→ or click a card · applied and saved at once', size: 17, color: Theme.dim, font: Theme::LIGHT)]
    Theme::ORDER.each { |name| out.concat(card(name)) }
    out
  end

  # One palette drawn in its own colours: name, swatches, and a sample row.
  def card name
    r = card_rect(name)
    c = Theme.colors(name)
    lit = name == Theme.current
    hover = Pointer.over?(r) && @index.zero?
    edge = if lit then c[:accent]
           elsif hover then c[:select]
           else c[:lines]
           end
    out = [Hud.rect(r.x, r.y, r.w, r.h, c[:bg]), Hud.rect(r.x + 8, r.y + 8, r.w - 16, r.h - 16, c[:panel])]
    out.concat([[r.x, r.y, r.w, 2], [r.x, r.y + r.h - 2, r.w, 2], [r.x, r.y, 2, r.h], [r.x + r.w - 2, r.y, 2, r.h]].map { |x, y, w, h| Hud.rect(x, y, w, h, edge) })
    out << Hud.text(r.x + 24, r.y + r.h - 34, Theme::PALETTES[name][:name], size: 26, color: c[:accent], font: Theme::EXTRABOLD)
    out << Hud.text(r.x + r.w - 24, r.y + r.h - 34, lit ? "#{Theme::CHECK} IN USE" : '', size: 15, color: c[:ok], font: Theme::BOLD, ax: 1)
    out << Hud.text(r.x + 24, r.y + r.h - 64, Theme::PALETTES[name][:about], size: 16, color: c[:dim], font: Theme::LIGHT)
    %i[lines dim text accent select fail].each_with_index { |key, i| out << Hud.rect(r.x + 24 + i * 40, r.y + 70, 30, 30, c[key]) }
    out << Hud.text(r.x + 24, r.y + 38, '▸ project-1bit', size: 18, color: c[:select], font: Theme::BOLD)
    out << Hud.text(r.x + 200, r.y + 38, "#{Theme::CHECK} 53 #{Theme::CROSS} 2", size: 18, color: c[:ok])
  end

  def folders_pane
    out = [Hud.text(X + 28, Y + 528, 'FOLDERS', size: 34, color: Theme.accent, font: Theme::EXTRABOLD),
           Hud.text(X + 28, Y + 484, 'DRPM only looks in these', size: 17, color: Theme.dim, font: Theme::LIGHT)]
    Settings::FOLDERS.each_with_index do |key, i|
      y = Y + 420 - i * 70
      path = Paths.send(key).to_s
      out << Hud.text(X + 28, y, key.to_s.upcase, size: 16, color: Theme.dim, font: Theme::BOLD)
      out << Hud.text(X + 28, y - 28, path.empty? ? '— none —' : path[-60, 60] || path, size: 19, color: path.empty? ? Theme.dim : Theme.text)
    end
    hover = Pointer.over?(x: X + 28, y: Y + 160, w: 300, h: 56)
    out + [Hud.rect(X + 28, Y + 160, 300, 56, hover ? Theme.select : Theme.accent, hover ? 90 : 40), Hud.rect(X + 28, Y + 160, 300, 1, hover ? Theme.select : Theme.accent),
           Hud.text(X + 178, Y + 188, "#{Theme::FOLDER} CHANGE · ENTER", size: 19, color: Theme.text, font: Theme::BOLD, ax: 0.5)]
  end

  def sound_pane
    on = !Blip.muted
    [Hud.text(X + 28, Y + 528, 'SOUND', size: 34, color: Theme.accent, font: Theme::EXTRABOLD),
     Hud.text(X + 28, Y + 484, 'blips on move and select, a chime or a low tone when tests finish', size: 17, color: Theme.dim, font: Theme::LIGHT),
     Hud.rect(X + 28, Y + 360, 300, 90, on ? Theme.ok : Theme.lines, (on ? 50 : 120) + (Pointer.over?(x: X + 28, y: Y + 360, w: 300, h: 90) ? 50 : 0)),
     Hud.text(X + 178, Y + 405, on ? "#{Theme::NOTE} ON" : "#{Theme::NOTE} OFF", size: 40, color: on ? Theme.ok : Theme.dim, font: Theme::EXTRABOLD, ax: 0.5),
     Hud.text(X + 28, Y + 320, 'ENTER or ←/→ switches it · M does too, anywhere', size: 17, color: Theme.dim)]
  end
end
