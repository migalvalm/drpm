# The right pane for the selected game: its name, a readout of metadata, git and tests (typed in when the
# selection changes), and the action keys, which can be clicked.
module Details
  X = 452
  Y = 72
  W = 804
  H = 584
  COL = 216   # where values start
  ACTIONS = [['P', 'PLAY', :play], ['T', 'TESTS', :tests], ['O', 'OPEN', :open], ['N', 'NEW', :new]].freeze

  def self.draw name, info, session, since, grow
    out = Hud.frame(X, Y, W, H, 'DETAILS', grow)
    return out if grow < 0.9 || !name

    out << Hud.text(X + 28, Y + H - 56, Hud.reveal(name.upcase, since, 3), size: 40, color: Theme::ACCENT, font: Theme::EXTRABOLD)
    out << Hud.text(X + 48 + Hud.width(name.upcase, 40, Theme::EXTRABOLD), Y + H - 56, '/' * 12, size: 26, color: Theme::LINES, font: Theme::LIGHT)
    readouts(name, info, session).each_with_index { |line, i| out.concat(readout(line, i, since)) }
    out.concat(running(session)) if session.running? && session.run.name == name
    out.concat(actions)
  end

  # [label, value, colour] lines.
  def self.readouts name, info, session
    meta = info[:meta]
    git = info[:git]
    [['TITLE', meta[:gametitle] || '—', Theme::TEXT], ['VERSION', meta[:version] || '—', Theme::TEXT],
     ['DEVELOPER', meta[:devtitle] || '—', Theme::TEXT], branch(git), commit(git),
     ['EDITED', info[:edited] ? Ago.since(info[:edited]) : '—', Theme::TEXT], tests(name, session)]
  end

  def self.branch git
    return ['BRANCH', 'not a git repo', Theme::DIM] unless git[:repo]

    changed = git[:changed].zero? ? 'clean' : "#{git[:changed]} changed"
    ['BRANCH', "#{Theme::BRANCH} #{git[:branch]} · #{changed}", git[:changed].zero? ? Theme::OK : Theme::SELECT]
  end

  def self.commit git
    ['LAST COMMIT', git[:last] ? git[:last][0, 44] : 'no commits yet', git[:last] ? Theme::TEXT : Theme::DIM]
  end

  def self.tests name, session
    return ['TESTS', "running · #{session.run.summary[:runs]}/#{session.run.files.size} files", Theme::ACCENT] if session.running? && session.run.name == name

    r = session.results[name]
    return ['TESTS', 'never run · press T', Theme::DIM] unless r

    ['TESTS', "#{Theme::CHECK} #{r[:passed]}  #{Theme::CROSS} #{r[:failed]}  · #{Ago.since(r[:at])}", r[:failed].zero? ? Theme::OK : Theme::FAIL]
  end

  def self.readout line, index, since
    label, value, color = line
    y = Y + H - 120 - index * 40
    start = since + 6 + index * 4
    [Hud.text(X + 28, y, Hud.reveal(Hud.readout(label, '', 13).rstrip, start, 3), size: 20, color: Theme::DIM, font: Theme::LIGHT),
     Hud.text(X + COL, y, Hud.reveal(value, start + 4, 3), size: 20, color: color)]
  end

  # The live run under the readout: a pulsing light and a segmented bar.
  def self.running session
    [Hud.text(X + 28, Y + 132, '●', size: 18, color: Theme::ACCENT, a: Hud.pulse),
     Hud.text(X + 52, Y + 132, "#{session.run.label} · #{session.run.summary[:passed]} passed · #{session.run.summary[:failed]} failed",
              size: 17, color: Theme::TEXT)] + Hud.bar(X + 28, Y + 102, W - 56, session.run.progress)
  end

  # The key strip; returns primitives. action_at tells which one a click hit.
  def self.actions
    ACTIONS.each_with_index.flat_map do |(key, label, _), i|
      x = X + 28 + i * 150
      [Hud.rect(x, Y + 26, 30, 30, Theme::ACCENT, 40), Hud.rect(x, Y + 26, 30, 1, Theme::ACCENT),
       Hud.text(x + 15, Y + 41, key, size: 18, color: Theme::ACCENT, font: Theme::BOLD, ax: 0.5),
       Hud.text(x + 42, Y + 41, label, size: 18, color: Theme::TEXT, font: Theme::BOLD)]
    end
  end

  def self.action_at mouse
    return nil unless mouse.y.between?(Y + 20, Y + 62)

    i = (mouse.x - X - 28).div(150)
    ACTIONS[i][2] if i >= 0 && i < ACTIONS.size && (mouse.x - X - 28) % 150 < 130
  end
end
