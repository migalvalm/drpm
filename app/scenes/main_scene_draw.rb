# MainScene's drawing: header, the two panes (details, form or output on the right), the bottom bar, effects.
class MainScene
  HINTS = [['↑↓', 'select'], ['P', 'play'], ['T', 'tests'], ['O', 'open'], ['N', 'new'], ['M', 'sound'], [':', 'command']].freeze

  def draw
    grow = Hud.ease(@opened, 24)
    out = Chrome.header(@session, 'projects')
    out.concat(GameList.draw(@games, @edits, @index, @slide_y, @session, grow))
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
    else Details.draw(selected, selected ? info(selected) : nil, @session, @since, grow)
    end
  end

  def output_lines
    title, lines = @output
    out = [Hud.text(Details::X + 28, Details::Y + 528, title, size: 22, color: Theme::ACCENT, font: Theme::BOLD)]
    lines.first(17).each_with_index do |line, i|
      out << Hud.text(Details::X + 28, Details::Y + 484 - i * 26, Hud.reveal(line[0, 70], @since + i * 2, 4), size: 17, color: Theme::TEXT)
    end
    out << Hud.text(Details::X + 28, Details::Y + 41, 'ESC back', size: 16, color: Theme::DIM)
  end

  # The last message, above the action keys, fading out after 4 seconds.
  def note_line
    text, at = @note
    age = Kernel.tick_count - at
    return [] if age > 240

    [Hud.text(Details::X + 28, Details::Y + 84, text, size: 18, color: Theme::SELECT, a: (255 - [age - 180, 0].max * 4).clamp(0, 255))]
  end
end
