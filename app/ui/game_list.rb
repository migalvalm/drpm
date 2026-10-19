# The left pane: games newest-edited first, the selection a magenta bar that slides between rows,
# and per game how long since its last edit and its last test result (a dot).
module GameList
  X = 24
  Y = 72
  W = 404
  H = 584
  ROW = 40
  ROWS = 12
  BUTTON = { x: X + 16, y: Y + 16, w: W - 32, h: 46 }.freeze   # + NEW PROJECT, under the list
  TOP = Y + H - 52   # first row's centre

  # The row index for list position i, given the scroll so selected stays in view.
  def self.offset selected, count
    (selected - ROWS + 1).clamp(0, [count - ROWS, 0].max)
  end

  def self.row_y i, offset
    TOP - (i - offset) * ROW
  end

  # Which game a mouse point is on, or nil.
  def self.hit mouse, count, offset
    return nil unless mouse.x.between?(X, X + W)

    i = offset + ((TOP + ROW / 2 - mouse.y).div(ROW))
    i if i >= offset && i < [count, offset + ROWS].min && mouse.y <= TOP + ROW / 2
  end

  # title: the frame's tab; dots: show each entry's test status (games yes, test files no);
  # button: draw + NEW PROJECT under the list, focused when selected == games.size.
  def self.draw games, edits, selected, slide_y, session, grow, title: 'PROJECTS', dots: true, button: false
    offset = offset(selected, games.size)
    out = Hud.frame(X, Y, W, H, "#{title} · #{games.size}", grow)
    return out if grow < 0.9

    out << Hud.rect(X + 2, slide_y - 17, W - 4, 34, Theme.select, 45) << Hud.rect(X + 2, slide_y - 17, 3, 34, Theme.select) if selected < games.size
    out.concat(new_button(selected == games.size)) if button
    games.each_with_index { |name, i| out.concat(row(name, i, offset, i == selected, edits, dots && session)) if i >= offset && i < offset + ROWS }
    out << Hud.text(X + 20, TOP, 'nothing here yet · press N for a new game', size: 18, color: Theme.dim) if games.empty?
    out
  end

  def self.row name, i, offset, lit, edits, session
    y = row_y(i, offset)
    edited = edits[name] ? Ago.since(edits[name]).delete_suffix(' ago') : ''
    [Hud.text(X + 20, y, "#{lit ? '▸' : ' '} #{name}", size: 20, color: lit ? Theme.select : Theme.text, font: lit ? Theme::BOLD : Theme::REGULAR),
     Hud.text(X + W - 44, y, edited, size: 15, color: Theme.dim, ax: 1)] + (session ? [status(name, X + W - 22, y, session)] : [])
  end

  # + NEW PROJECT: outlined, filled magenta when focused.
  def self.new_button lit
    b = BUTTON
    edge = lit ? Theme.select : Theme.accent
    [Hud.rect(b.x, b.y, b.w, b.h, lit ? Theme.select : Theme.accent, lit ? 70 : 25),
     Hud.rect(b.x, b.y, b.w, 1, edge), Hud.rect(b.x, b.y + b.h - 1, b.w, 1, edge), Hud.rect(b.x, b.y, 1, b.h, edge), Hud.rect(b.x + b.w - 1, b.y, 1, b.h, edge),
     Hud.text(b.x + b.w / 2, b.y + b.h / 2, '+ NEW PROJECT', size: 19, color: lit ? Theme.text : Theme.accent, font: Theme::BOLD, ax: 0.5),
     Hud.text(b.x + b.w - 14, b.y + b.h / 2, 'N', size: 15, color: Theme.dim, font: Theme::BOLD, ax: 1)]
  end

  # ● green/red for the last result, a pulsing cyan ● while its tests run, ○ when never run.
  def self.status name, x, y, session
    return Hud.text(x, y, '●', size: 16, color: Theme.accent, ax: 0.5, a: Hud.pulse) if session.running? && session.run.name == name

    result = session.results[name]
    return Hud.text(x, y, '○', size: 16, color: Theme.dim, ax: 0.5) unless result

    Hud.text(x, y, '●', size: 16, color: result[:failed].zero? ? Theme.ok : Theme.fail, ax: 0.5)
  end
end
