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

    out << Hud.text(X + 28, Y + H - 56, Hud.reveal(name.upcase, since, 3), size: 40, color: Theme.accent, font: Theme::EXTRABOLD)
    out << Hud.text(X + 48 + Hud.width(name.upcase, 40, Theme::EXTRABOLD), Y + H - 56, '/' * 12, size: 26, color: Theme.lines, font: Theme::LIGHT)
    readouts(name, info, session).each_with_index { |line, i| out.concat(readout(line, i, since)) }
    out.concat(running(session)) if session.running_for?(name)
    out.concat(actions)
  end

  # [label, value, colour] lines.
  def self.readouts name, info, session
    meta = info[:meta]
    git = info[:git]
    [['TITLE', meta[:gametitle] || '—', Theme.text], ['VERSION', meta[:version] || '—', Theme.text],
     ['DEVELOPER', meta[:devtitle] || '—', Theme.text], branch(git), commit(git),
     ['EDITED', info[:edited] ? Ago.since(info[:edited]) : '—', Theme.text], tests(name, session)]
  end

  def self.branch git
    return ['BRANCH', 'not a git repo', Theme.dim] unless git[:repo]

    changed = git[:changed].zero? ? 'clean' : "#{git[:changed]} changed"
    ['BRANCH', "#{Theme::BRANCH} #{git[:branch]} · #{changed}", git[:changed].zero? ? Theme.ok : Theme.select]
  end

  def self.commit git
    ['LAST COMMIT', git[:last] ? git[:last][0, 44] : 'no commits yet', git[:last] ? Theme.text : Theme.dim]
  end

  def self.tests name, session
    return ['TESTS', "running · #{session.run.summary[:runs]}/#{session.run.files.size} files", Theme.accent] if session.running_for?(name)

    r = session.results[name]
    return ['TESTS', 'never run · press T', Theme.dim] unless r

    ['TESTS', "#{Theme::CHECK} #{r[:passed]}  #{Theme::CROSS} #{r[:failed]}  · #{Ago.since(r[:at])}", r[:failed].zero? ? Theme.ok : Theme.fail]
  end

  def self.readout line, index, since
    label, value, color = line
    y = Y + H - 120 - index * 40
    start = since + 6 + index * 4
    [Hud.text(X + 28, y, Hud.reveal(Hud.readout(label, '', 13).rstrip, start, 3), size: 20, color: Theme.dim, font: Theme::LIGHT),
     Hud.text(X + COL, y, Hud.reveal(value, start + 4, 3), size: 20, color: color)]
  end

  # The live run under the readout: a pulsing light and a segmented bar.
  def self.running session
    [Hud.text(X + 28, Y + 132, '●', size: 18, color: Theme.accent, a: Hud.pulse),
     Hud.text(X + 52, Y + 132, "#{session.run.label} · #{session.run.summary[:passed]} passed · #{session.run.summary[:failed]} failed",
              size: 17, color: Theme.text)] + Hud.bar(X + 28, Y + 102, W - 56, session.run.progress)
  end

  # The key strip; returns primitives. action_at tells which one a click hit. Under the mouse a key fills in.
  def self.actions
    ACTIONS.each_with_index.flat_map do |(key, label, _), i|
      x = X + 28 + i * 150
      hover = Pointer.over?(x: x - 6, y: Y + 20, w: 136, h: 42)
      key_color = hover ? Theme.select : Theme.accent
      (hover ? [Hud.rect(x - 6, Y + 20, 136, 42, Theme.select, 35)] : []) +
        [Hud.rect(x, Y + 26, 30, 30, key_color, hover ? 110 : 40), Hud.rect(x, Y + 26, 30, 1, key_color),
         Hud.text(x + 15, Y + 41, key, size: 18, color: hover ? Theme.text : Theme.accent, font: Theme::BOLD, ax: 0.5),
         Hud.text(x + 42, Y + 41, label, size: 18, color: hover ? Theme.select : Theme.text, font: Theme::BOLD)]
    end
  end

  def self.action_at mouse
    return nil unless mouse.y.between?(Y + 20, Y + 62)

    i = (mouse.x - X - 28).div(150)
    ACTIONS[i][2] if i >= 0 && i < ACTIONS.size && (mouse.x - X - 28) % 150 < 130
  end
end
