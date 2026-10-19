# Soft UI sounds: move, select, back, type, pass, fail (sounds/*.wav). One key per sound, so a sound restarts
# rather than stacking. Muted with M or in Settings (which remembers it).
module Blip
  GAIN = { move: 0.5, select: 0.6, back: 0.6, type: 0.35, pass: 0.7, fail: 0.7 }.freeze

  class << self
    attr_accessor :muted
  end

  def self.play audio, name
    return if muted

    audio[name] = { input: "sounds/#{name}.wav", gain: GAIN[name] }
  end
end
