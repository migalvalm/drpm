module Buttons
  LOOK     = { path: :solid, r: 90, g: 20, b: 20 }.freeze
  LOOK_LIT = { path: :solid, r: 150, g: 150, b: 150 }.freeze


  def self.draw outputs, mouse, buttons, keys = {}
    hover = buttons.index { |b| mouse.inside_rect? b }
    @focus = 0 unless buttons == @buttons      # a new menu starts on its first button
    @buttons = buttons
    @focus = hover if hover && mouse.moved
    @focus = (@focus + step(keys)).clamp(0, buttons.size - 1)
    lit = keys.empty? ? hover : @focus
    buttons.each_with_index { |button, i| button outputs, button, i == lit }
    return buttons[@focus] if keys[:enter]
    mouse.click && hover && buttons[hover]
  end

  def self.step keys
    (keys[:down] || keys[:right] ? 1 : 0) - (keys[:up] || keys[:left] ? 1 : 0)
  end

  def self.button outputs, button, lit
    outputs.sprites << button.merge(lit ? LOOK_LIT : LOOK)
    outputs.labels << { font: FONT, x: button.x + button.w / 2, y: button.y + button.h / 2 + 4,   # +4: monogram sits low in its line box
                        text: button.text, size_px: 30, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
  end
end
