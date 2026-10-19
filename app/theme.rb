# The HUD's look: JetBrainsMono Nerd Font Mono weights and the cyan + magenta palette ({ r:, g:, b: } hashes).
module Theme
  def self.rgb hex
    r, g, b = Color.hex(hex)
    { r: r, g: g, b: b }.freeze
  end

  LIGHT     = 'fonts/JetBrainsMonoNerdFontMono-Light.ttf'.freeze
  REGULAR   = 'fonts/JetBrainsMonoNerdFontMono-Regular.ttf'.freeze
  BOLD      = 'fonts/JetBrainsMonoNerdFontMono-Bold.ttf'.freeze
  EXTRABOLD = 'fonts/JetBrainsMonoNerdFontMono-ExtraBold.ttf'.freeze

  BG     = rgb('#070b14')
  PANEL  = rgb('#0b1322')
  LINES  = rgb('#1f6f8b')
  DIM    = rgb('#5f8aa0')
  TEXT   = rgb('#cfeffc')
  ACCENT = rgb('#3ef0ff')
  SELECT = rgb('#ff3ea5')
  OK     = rgb('#5dffa0')
  FAIL   = rgb('#ff5d6c')

  # Nerd Font icons
  BRANCH = "\u{e0a0}".freeze
  CHECK  = "\u{f00c}".freeze
  CROSS  = "\u{f00d}".freeze
  PLAY   = "\u{f04b}".freeze
  FOLDER = "\u{f07b}".freeze
  BUG    = "\u{f188}".freeze
  NOTE   = "\u{f001}".freeze
end
