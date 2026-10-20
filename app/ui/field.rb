# A one-line text input drawn in HUD style. The scene feeds it the characters typed this tick and key_down.
class Field
  attr_accessor :text

  W = 520
  H = 40
  SHOWN = 72   # longer text shows its end, after an ellipsis

  # allowed = a String of the characters it accepts (nil = any); w = the box width.
  def initialize text = '', max = 32, allowed = nil, w = W
    @text, @max, @allowed, @w = text, max, allowed, w
  end

  def update chars, keys
    chars.join.each_char { |c| @text += c if @text.size < @max && c != "\t" && (!@allowed || @allowed.include?(c)) }
    @text = @text[0...-1] if keys.backspace
  end

  def draw x, y, focused
    hover = Pointer.over?({ x: x, y: y, w: @w, h: H }, 'ibeam')
    edge = if focused then Theme.accent
           elsif hover then Theme.dim
           else Theme.lines
           end
    caret = focused && Kernel.tick_count.div(20).even? ? '█' : ''
    shown = @text.size > SHOWN ? "…#{@text[(@text.size - SHOWN), SHOWN]}" : @text
    [Hud.rect(x, y, @w, H, Theme.bg), *Hud.outline(x, y, @w, H, edge),
     Hud.text(x + 12, y + H / 2, shown + caret, size: 20, color: focused ? Theme.text : Theme.dim)]
  end
end
