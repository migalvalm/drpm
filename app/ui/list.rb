module List
  ROWS = 12
  W    = 380
  H    = 40
  STEP = 46

  def self.buttons values, x, top
    values.each_with_index.map do |value, i|
      { x: x + i.div(ROWS) * (W + 20), y: top - i % ROWS * STEP, w: W, h: H, text: value, value: value }
    end
  end
end