# A one-line text input drawn in HUD style. Plain class: the scene feeds it the characters typed this tick
# (inputs.text) and the keyboard's key_down; text input stays on for the whole launcher.
class Field
  attr_accessor :text

  W = 520
  H = 40

  # allowed = a String of the characters it accepts (nil = any).
  def initialize text = '', max = 32, allowed = nil
    @text, @max, @allowed = text, max, allowed
  end

  def update chars, keys
    chars.join.each_char { |c| @text += c if @text.size < @max && (!@allowed || @allowed.include?(c)) }
    @text = @text[0...-1] if keys.backspace
  end

  # The box at x, y (bottom-left), brighter and with a caret when focused.
  def draw x, y, focused
    edge = focused ? Theme.accent : Theme.lines
    caret = focused && Kernel.tick_count.div(20).even? ? '█' : ''
    [Hud.rect(x, y, W, H, Theme.bg), Hud.rect(x, y, W, 1, edge), Hud.rect(x, y + H - 1, W, 1, edge),
     Hud.rect(x, y, 1, H, edge), Hud.rect(x + W - 1, y, 1, H, edge),
     Hud.text(x + 12, y + H / 2, @text + caret, size: 22, color: focused ? Theme.text : Theme.dim)]
  end
end
