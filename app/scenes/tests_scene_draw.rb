# TestsScene's drawing: the file list, then the run (or the last result) with totals, a bar and failures.
class TestsScene
  X = 452
  Y = 72
  W = 804
  H = 584

  def draw
    grow = Hud.ease(@opened, 24)
    out = Chrome.header(@session, "tests / #{@name}")
    out.concat(GameList.draw(@entries, {}, @index, GameList.row_y(@index, GameList.offset(@index, @entries.size)), @session, grow, title: 'FILES', dots: false))
    out.concat(Hud.frame(X, Y, W, H, 'RUN', grow))
    out.concat(run ? live : last) if grow > 0.9
    out << Hud.text(X + 28, Y + 70, @note, size: 18, color: Theme.fail) if @note
    out.concat(Chrome.keys([['↑↓', 'select'], ['ENTER', 'run'], ['ESC', 'back']]))
    outputs.primitives << out
    Fx.draw outputs
  end

  def live
    s = run.summary
    state = run.done? ? Hud.text(X + 28, Y + 480, 'DONE', size: 22, color: s[:failed].zero? ? Theme.ok : Theme.fail, font: Theme::BOLD)
                      : Hud.text(X + 28, Y + 480, '● RUNNING', size: 22, color: Theme.accent, font: Theme::BOLD, a: Hud.pulse)
    [Hud.text(X + 28, Y + 528, run.label.upcase, size: 34, color: Theme.accent, font: Theme::EXTRABOLD), state,
     Hud.text(X + W - 28, Y + 480, "#{s[:runs]}/#{run.files.size} files", size: 18, color: Theme.dim, ax: 1)] +
      Hud.bar(X + 28, Y + 440, W - 56, run.progress, run.done? && s[:failed].positive? ? Theme.fail : Theme.accent) +
      totals(s[:passed], s[:failed]) + failures(s[:failures])
  end

  def totals passed, failed
    [Hud.text(X + 28, Y + 370, "#{Theme::CHECK} #{passed}", size: 52, color: Theme.ok, font: Theme::EXTRABOLD),
     Hud.text(X + 300, Y + 370, "#{Theme::CROSS} #{failed}", size: 52, color: failed.zero? ? Theme.dim : Theme.fail, font: Theme::EXTRABOLD)]
  end

  def failures names
    names.first(9).each_with_index.map do |test, i|
      Hud.text(X + 28, Y + 300 - i * 26, "#{Theme::BUG} #{test.delete_prefix('test_')[0, 64]}", size: 17, color: Theme.fail)
    end
  end

  # No run for this game here yet: its last result, if any.
  def last
    r = @session.results[@name]
    text = r ? "last run #{Ago.since(r[:at])}" : 'never run'
    [Hud.text(X + 28, Y + 528, @name.upcase, size: 34, color: Theme.accent, font: Theme::EXTRABOLD),
     Hud.text(X + 28, Y + 480, "#{text} · ENTER runs the selected file", size: 18, color: Theme.dim)] + (r ? totals(r[:passed], r[:failed]) : [])
  end
end
