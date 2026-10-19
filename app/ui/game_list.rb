# The left pane: games newest-edited first, the selection a magenta bar that slides between rows,
# and per game how long since its last edit and its last test result (a dot).
module GameList
  X = 24
  Y = 72
  W = 404
  H = 584
  ROW = 40
  ROWS = 13
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

  # title: the frame's tab; dots: show each entry's test status (games yes, test files no).
  def self.draw games, edits, selected, slide_y, session, grow, title = 'PROJECTS', dots = true
    offset = offset(selected, games.size)
    out = Hud.frame(X, Y, W, H, "#{title} · #{games.size}", grow)
    return out if grow < 0.9

    out << Hud.rect(X + 2, slide_y - 17, W - 4, 34, Theme::SELECT, 45) << Hud.rect(X + 2, slide_y - 17, 3, 34, Theme::SELECT) if games.any?
    games.each_with_index { |name, i| out.concat(row(name, i, offset, i == selected, edits, dots && session)) if i >= offset && i < offset + ROWS }
    out << Hud.text(X + 20, TOP, 'nothing here yet · press N for a new game', size: 18, color: Theme::DIM) if games.empty?
    out
  end

  def self.row name, i, offset, lit, edits, session
    y = row_y(i, offset)
    edited = edits[name] ? Ago.since(edits[name]).delete_suffix(' ago') : ''
    [Hud.text(X + 20, y, "#{lit ? '▸' : ' '} #{name}", size: 20, color: lit ? Theme::SELECT : Theme::TEXT, font: lit ? Theme::BOLD : Theme::REGULAR),
     Hud.text(X + W - 44, y, edited, size: 15, color: Theme::DIM, ax: 1)] + (session ? [status(name, X + W - 22, y, session)] : [])
  end

  # ● green/red for the last result, a pulsing cyan ● while its tests run, ○ when never run.
  def self.status name, x, y, session
    return Hud.text(x, y, '●', size: 16, color: Theme::ACCENT, ax: 0.5, a: Hud.pulse) if session.running? && session.run.name == name

    result = session.results[name]
    return Hud.text(x, y, '○', size: 16, color: Theme::DIM, ax: 0.5) unless result

    Hud.text(x, y, '●', size: 16, color: result[:failed].zero? ? Theme::OK : Theme::FAIL, ax: 0.5)
  end
end
