# Screen effects drawn over everything: scanlines, a slow bright sweep down the screen, and a dark edge.
module Fx
  SCANLINES = (0...180).map { |i| { x: 0, y: i * 4, w: 1280, h: 1, path: :solid, r: 0, g: 0, b: 0, a: 55 } }.freeze
  SWEEP_EVERY = 420   # ticks between sweeps
  SWEEP_H = 90

  def self.draw outputs
    outputs.primitives << SCANLINES
    outputs.primitives << sweep
    outputs.primitives << vignette
  end

  # A soft band of light that runs down the screen every SWEEP_EVERY ticks.
  def self.sweep
    t = Kernel.tick_count % SWEEP_EVERY
    return [] if t > 160

    top = 720 + SWEEP_H - (t * 5.5)
    (0...9).map do |i|
      { x: 0, y: (top - i * 10).to_i, w: 1280, h: 10, path: :solid, a: (14 - (i - 4).abs * 3).clamp(2, 14) }.merge(Theme::ACCENT)
    end
  end

  # Darker bands along the top and bottom edges, like a curved screen.
  def self.vignette
    (0...6).flat_map do |i|
      a = 60 - i * 10
      [{ x: 0, y: i * 6, w: 1280, h: 6, path: :solid, r: 0, g: 0, b: 0, a: a },
       { x: 0, y: 714 - i * 6, w: 1280, h: 6, path: :solid, r: 0, g: 0, b: 0, a: a }]
    end
  end
end
