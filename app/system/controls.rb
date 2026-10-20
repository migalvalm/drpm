# Keyboard and pad as one set of presses, named after the keyboard keys the scenes read.
# Pad: d-pad = arrows, A = Enter/Space, Start = Esc. Add an action = one PAD line. Movement stays inputs.left_right / up_down.
module Controls
  PAD = { up: [:up], down: [:down], left: [:left], right: [:right], enter: [:a], space: [:a], escape: [:start] }.freeze

  # What was pressed this tick, every PAD key present (true/false).
  def self.down inputs
    kb = inputs.keyboard.key_down
    pad = inputs.controller_one.key_down
    PAD.map { |key, buttons| [key, !!(kb.send(key) || buttons.any? { |b| pad.send(b) })] }.to_h
  end

  # 1 for down, -1 for up, from a down result.
  def self.step keys
    (keys[:down] ? 1 : 0) - (keys[:up] ? 1 : 0)
  end
end
