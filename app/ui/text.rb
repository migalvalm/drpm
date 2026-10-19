module Text
    GREY = { r: 160, g: 160, b: 160 }.freeze
    RED = { r: 255, g: 120, b: 120 }.freeze
    GREEN = { r: 120, g: 220, b: 140 }.freeze

    def self.label x, y, text, more = {}
      { font: FONT, x: x, y: y, text: text, size_px: 30, anchor_y: 0.5, r: 255, g: 255, b: 255 }.merge(more)
    end
end