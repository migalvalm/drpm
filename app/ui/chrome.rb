# What frames every screen: the header bar (name, where you are, SDK, sound, clock) and the key hints along the bottom.
module Chrome
  RIGHT = 1256
  GAP = 28

  def self.header session, where
    out = [Hud.rect(24, 678, 1232, 1, Theme.lines), Hud.rect(24, 677, 1232, 3, Theme.lines, 60),
           Hud.text(24, 698, '◆ DRAGONRUBY // DRPM', size: 20, color: Theme.accent, font: Theme::EXTRABOLD),
           Hud.text(40 + Hud.width('◆ DRAGONRUBY // DRPM', 20, Theme::EXTRABOLD), 698, "/ #{where}", size: 20, color: Theme.dim, font: Theme::LIGHT)]
    x = RIGHT
    settings_hover = Pointer.over?(settings_rect(session))
    right_items(session).each_with_index do |(text, color), i|
      color = Theme.select if i == 1 && settings_hover
      out << Hud.text(x, 698, text, size: 17, color: color, ax: 1)
      x -= Hud.width(text, 17) + GAP
    end
    out
  end

  # Right to left: clock, settings, sound, SDK.
  def self.right_items session
    now = Time.now
    [["#{now.hour.to_s.rjust(2, '0')}:#{now.min.to_s.rjust(2, '0')}", Theme.text], ["#{Theme::GEAR} SETTINGS", Theme.accent],
     [Blip.muted ? "#{Theme::NOTE} OFF" : "#{Theme::NOTE} ON", Theme.text], [SdkInfo.label(session.sdk), Theme.text]]
  end

  # Where the header's settings item is, for clicks.
  def self.settings_rect session
    clock, settings = right_items(session).first(2).map(&:first)
    right = RIGHT - Hud.width(clock, 17) - GAP
    w = Hud.width(settings, 17)
    { x: right - w, y: 684, w: w, h: 28 }
  end

  # hints: [[key, what], ...]
  def self.keys hints
    x = 24
    hints.flat_map do |key, what|
      key_w = Hud.width(key, 16, Theme::BOLD)
      out = [Hud.text(x, 38, key, size: 16, color: Theme.accent, font: Theme::BOLD),
             Hud.text(x + key_w + 8, 38, what, size: 16, color: Theme.dim)]
      x += key_w + Hud.width(what, 16) + 32
      out
    end
  end
end
