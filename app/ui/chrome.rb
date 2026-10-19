# What frames every screen: the header bar (name, where you are, SDK, sound, clock) and the key hints along the bottom.
module Chrome
  def self.header session, where
    now = Time.now
    clock = "#{now.hour.to_s.rjust(2, '0')}:#{now.min.to_s.rjust(2, '0')}"
    sound = Blip.muted ? "#{Theme::NOTE} OFF" : "#{Theme::NOTE} ON"
    [Hud.rect(24, 678, 1232, 1, Theme::LINES), Hud.rect(24, 677, 1232, 3, Theme::LINES, 60),
     Hud.text(24, 698, '◆ DRAGONRUBY // LAUNCHER', size: 20, color: Theme::ACCENT, font: Theme::EXTRABOLD),
     Hud.text(40 + Hud.width('◆ DRAGONRUBY // LAUNCHER', 20, Theme::EXTRABOLD), 698, "/ #{where}", size: 20, color: Theme::DIM, font: Theme::LIGHT),
     Hud.text(1256, 698, "#{SdkInfo.label(session.sdk)}    #{sound}    #{clock}", size: 17, color: Theme::TEXT, ax: 1)]
  end

  # hints: [[key, what], ...]
  def self.keys hints
    x = 24
    hints.flat_map do |key, what|
      key_w = Hud.width(key, 16, Theme::BOLD)
      out = [Hud.text(x, 38, key, size: 16, color: Theme::ACCENT, font: Theme::BOLD),
             Hud.text(x + key_w + 8, 38, what, size: 16, color: Theme::DIM)]
      x += key_w + Hud.width(what, 16) + 32
      out
    end
  end
end
