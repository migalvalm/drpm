# The `:` command line along the bottom: type, Tab completes (commands, then game names), Enter runs,
# Esc (or Backspace on an empty line) closes. Plain class.
class CommandBar
  attr_reader :line

  def initialize
    @line = ''
  end

  # Returns [:run, line], :close, or nil while typing.
  def update chars, keys, games
    return :close if keys.escape || (keys.backspace && @line.empty?)
    return [:run, @line] if keys.enter || keys.kp_enter

    @line = Command.complete(@line, games) if keys.tab
    chars.join.each_char { |c| @line += c unless c == "\t" }
    @line = @line[0...-1] if keys.backspace
    nil
  end

  # What Tab would complete to, shown dim after the typed text.
  def hint games
    done = Command.complete(@line, games)
    done.start_with?(@line) ? done[@line.size, done.size] : ''
  end

  def draw games
    caret = Kernel.tick_count.div(20).even? ? '█' : ' '
    [Hud.rect(24, 20, 1232, 36, Theme.panel), Hud.rect(24, 55, 1232, 1, Theme.accent),
     Hud.text(36, 38, ":#{@line}#{caret}", size: 22, color: Theme.accent, font: Theme::BOLD),
     Hud.text(36 + Hud.width(":#{@line}", 22, Theme::BOLD), 38, hint(games), size: 22, color: Theme.dim),
     Hud.text(1244, 38, 'TAB complete · ENTER run · ESC close', size: 15, color: Theme.dim, ax: 1)]
  end
end
