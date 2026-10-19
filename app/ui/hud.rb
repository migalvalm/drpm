# HUD drawing helpers. Everything goes through outputs.primitives in draw order, so the effects (Fx) can
# go on top of text. Each helper returns primitives (a Hash or an Array of them).
module Hud
  # A label. color: a Theme colour; ax/ay: anchors.
  def self.text x, y, str, size: 22, color: Theme.text, font: Theme::REGULAR, ax: 0, ay: 0.5, a: 255
    { x: x, y: y, text: str, size_px: size, font: font, anchor_x: ax, anchor_y: ay, a: a }.merge(color)
  end

  # How wide str is drawn, in pixels.
  def self.width str, size, font = Theme::REGULAR
    GTK.calcstringbox(str, size_px: size, font: font)[0]
  end

  def self.rect x, y, w, h, color, a = 255
    { x: x, y: y, w: w, h: h, path: :solid, a: a }.merge(color)
  end

  # A framed panel opened to grow (0..1) from its middle: fill, glowing edges, accent corner brackets, a title tab.
  def self.frame x, y, w, h, title = nil, grow = 1
    gw = (w * grow).to_i
    gh = (h * grow).to_i
    fx = x + (w - gw).div(2)
    fy = y + (h - gh).div(2)
    out = [rect(fx, fy, gw, gh, Theme.panel, 230)] + edges(fx, fy, gw, gh) + corners(fx, fy, gw, gh)
    out << tab(fx, fy + gh, title) if title && grow > 0.9
    out
  end

  # Edge lines, each with a soft glow line around it.
  def self.edges x, y, w, h
    [[x, y, w, 1], [x, y + h - 1, w, 1], [x, y, 1, h], [x + w - 1, y, 1, h]].flat_map do |lx, ly, lw, lh|
      [rect(lx - 1, ly - 1, lw + 2, lh + 2, Theme.lines, 70), rect(lx, ly, lw, lh, Theme.lines)]
    end
  end

  # Cyan L-brackets on the four corners.
  def self.corners x, y, w, h, len = 14
    [[x, y, 1, 1], [x + w, y, -1, 1], [x, y + h, 1, -1], [x + w, y + h, -1, -1]].flat_map do |cx, cy, dx, dy|
      [rect(dx.positive? ? cx : cx - len, dy.positive? ? cy : cy - 2, len, 2, Theme.accent),
       rect(dx.positive? ? cx : cx - 2, dy.positive? ? cy : cy - len, 2, len, Theme.accent)]
    end
  end

  # " TITLE " cut into the top edge.
  def self.tab x, top, title
    label = " #{title} "
    w = width(label, 15, Theme::BOLD)
    [rect(x + 18, top - 8, w, 16, Theme.bg), text(x + 18, top, label, size: 15, color: Theme.accent, font: Theme::BOLD)]
  end

  # The first part of str, typed in at speed chars per tick since start tick (whole string once done).
  def self.reveal str, start, speed = 2
    count = ((Kernel.tick_count - start) * speed).to_i
    count >= str.size ? str : str[0, count.clamp(0, str.size)]
  end

  # 0..1 easing (ease-out cubic) of the time since start over duration ticks.
  def self.ease start, duration
    t = ((Kernel.tick_count - start).fdiv(duration)).clamp(0, 1)
    1 - (1 - t)**3
  end

  # Alpha that pulses between low and 255.
  def self.pulse low = 90, speed = 0.12
    (low + (255 - low) * (0.5 + 0.5 * Math.sin(Kernel.tick_count * speed))).to_i
  end

  # "LABEL ....... value" with the label padded to width.
  def self.readout label, value, width = 14
    "#{label} #{'.' * [width - label.size, 2].max} #{value}"
  end

  # A segmented progress bar: filled segments in color, the rest dim.
  def self.bar x, y, w, progress, color = Theme.accent, segments = 24
    seg = w.fdiv(segments)
    lit = (progress * segments).round
    (0...segments).map { |i| rect((x + i * seg).to_i, y, (seg - 3).to_i, 12, i < lit ? color : Theme.lines, i < lit ? 255 : 120) }
  end
end
