# MainScene's drawing: header, the two panes (details, form or output on the right), the bottom bar, effects.
class MainScene
  HINTS = [['↑↓', 'select'], ['P', 'play'], ['T', 'tests'], ['O', 'open'], ['N', 'new'], ['S', 'settings'], ['M', 'sound'], [':', 'command']].freeze

  def draw
    grow = Hud.ease(@opened, 24)
    out = Chrome.header(@session, 'projects')
    out.concat(GameList.draw(@games, @edits, @index, @slide_y, @session, grow, button: true))
    out.concat(right_pane(grow))
    out.concat(note_line) if @note
    out.concat(@bar ? @bar.draw(@games) : Chrome.keys(HINTS))
    outputs.primitives << out
    Fx.draw outputs
  end

  def right_pane grow
    case @mode
    when :form then Hud.frame(Details::X, Details::Y, Details::W, Details::H, 'NEW', grow) + @form.draw(Details::X, Details::Y, @since)
    when :output then Hud.frame(Details::X, Details::Y, Details::W, Details::H, 'OUTPUT', grow) + output_lines
    else selected ? Details.draw(selected, info(selected), @session, @since, grow) : new_card(grow)
    end
  end

  # The right pane while + NEW PROJECT is focused: what it does and the templates it can use.
  def new_card grow
    out = Hud.frame(Details::X, Details::Y, Details::W, Details::H, 'NEW', grow)
    return out if grow < 0.9

    x = Details::X + 28
    out << Hud.text(x, Details::Y + 528, Hud.reveal('NEW PROJECT', @since, 2), size: 40, color: Theme.select, font: Theme::EXTRABOLD)
    out << Hud.text(x, Details::Y + 484, 'a copy of a template, in your projects folder', size: 17, color: Theme.dim, font: Theme::LIGHT)
    out << Hud.text(x, Details::Y + 420, 'START FROM', size: 18, color: Theme.accent, font: Theme::BOLD)
    templates.each_with_index { |t, i| out.concat(card_template(t, i)) }
    out << Hud.text(x, Details::Y + 41, 'click a template, or ENTER to start with the first', size: 16, color: Theme.dim)
  end

  # A template on the card: a button that opens the form with it chosen.
  def card_template template, index
    r = card_template_rect(index)
    hover = Pointer.over?(r)
    [Hud.rect(r.x, r.y, r.w, r.h, Theme.accent, hover ? 60 : 20), Hud.rect(r.x, r.y, 3, r.h, hover ? Theme.select : Theme.accent),
     Hud.text(r.x + 16, r.y + r.h / 2, "#{Theme::FOLDER}  #{template[:name]}", size: 20, color: Theme.text, font: hover ? Theme::BOLD : Theme::REGULAR),
     Hud.text(r.x + r.w - 16, r.y + r.h / 2, '▸', size: 20, color: hover ? Theme.select : Theme.dim, ax: 1)]
  end

  def card_template_rect index
    { x: Details::X + 28, y: Details::Y + 352 - index * 52, w: 480, h: 42 }
  end

  def templates
    @templates ||= Templates.list
  end

  def output_lines
    title, lines = @output
    out = [Hud.text(Details::X + 28, Details::Y + 528, title, size: 22, color: Theme.accent, font: Theme::BOLD)]
    lines.first(17).each_with_index do |line, i|
      out << Hud.text(Details::X + 28, Details::Y + 484 - i * 26, Hud.reveal(line[0, 70], @since + i * 2, 4), size: 17, color: Theme.text)
    end
    out << Hud.text(Details::X + 28, Details::Y + 41, 'ESC back', size: 16, color: Theme.dim)
  end

  # The last message, above the action keys, fading out after 4 seconds.
  def note_line
    text, at = @note
    age = Kernel.tick_count - at
    return [] if age > 240

    [Hud.text(Details::X + 28, Details::Y + 84, text, size: 18, color: Theme.select, a: (255 - [age - 180, 0].max * 4).clamp(0, 255))]
  end
end
