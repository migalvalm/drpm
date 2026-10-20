# SetupScene's drawing: one wide panel, a row per folder (label, what it is, the field, its check), SAVE.
class SetupScene
  def draw
    grow = Hud.ease(@opened, 24)
    out = Chrome.header(@session, 'setup')
    out.concat(Hud.frame(24, 72, 1232, 584, 'SETUP', grow))
    if grow > 0.9
      out << Hud.text(48, 612, Hud.reveal('WHERE ARE YOUR THINGS?', @opened, 2), size: 34, color: Theme.accent, font: Theme::EXTRABOLD)
      out << Hud.text(48, 574, 'DRPM only looks in these folders. Change them later in Settings > FOLDERS.', size: 17, color: Theme.dim, font: Theme::LIGHT)
      ROWS.each_with_index { |(key, label, about), i| out.concat(row(key, label, about, i)) }
      out.concat(save_button)
    end
    out.concat(Chrome.keys(hints))
    outputs.primitives << out
    Fx.draw outputs
  end

  def hints
    keys = [['↑↓', 'field'], ['TAB', 'complete'], ['CTRL+V', 'paste'], ['ENTER', 'check + next']]
    @editing ? keys + [['ESC', 'cancel']] : keys
  end

  def row key, label, about, index
    y = row_y(index)
    lit = index == @focus
    problem, found = @checks[key]
    out = [Hud.text(48, y + 26, label, size: 18, color: lit ? Theme.accent : Theme.dim, font: Theme::BOLD),
           Hud.text(260, y + 26, about, size: 15, color: Theme.dim, font: Theme::LIGHT)]
    out.concat(@fields[key].draw(48, y - 26, lit))
    out << Hud.text(48 + FIELD_W + 20, y - 6, problem || found, size: 17, color: problem ? Theme.fail : Theme.ok, font: Theme::BOLD)
  end

  def save_button
    r = save_rect
    hover = Pointer.over?(r)
    lit = @focus == ROWS.size || hover
    ready = ok?
    color = ready ? Theme.ok : Theme.lines
    [Hud.rect(r.x, r.y, r.w, r.h, color, lit ? 90 : 30), Hud.rect(r.x, r.y, r.w, 1, color), Hud.rect(r.x, r.y + r.h - 1, r.w, 1, color),
     Hud.text(r.x + r.w / 2, r.y + r.h / 2, "#{Theme::CHECK} SAVE", size: 20, color: ready ? Theme.text : Theme.dim, font: Theme::BOLD, ax: 0.5),
     Hud.text(r.x + r.w + 24, r.y + r.h / 2, ready ? 'ENTER saves and opens your projects' : 'fix the fields marked in red first', size: 16, color: Theme.dim)]
  end
end
