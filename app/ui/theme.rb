# The HUD's look: JetBrainsMono Nerd Font Mono weights, Nerd icons, and four colour palettes. Theme.accent etc.
# give the current palette's colour as { r:, g:, b: }; Theme.apply switches palette (Settings remembers which).
module Theme
  LIGHT     = 'fonts/JetBrainsMonoNerdFontMono-Light.ttf'.freeze
  REGULAR   = 'fonts/JetBrainsMonoNerdFontMono-Regular.ttf'.freeze
  BOLD      = 'fonts/JetBrainsMonoNerdFontMono-Bold.ttf'.freeze
  EXTRABOLD = 'fonts/JetBrainsMonoNerdFontMono-ExtraBold.ttf'.freeze

  BRANCH = "\u{e0a0}".freeze
  CHECK  = "\u{f00c}".freeze
  CROSS  = "\u{f00d}".freeze
  PLAY   = "\u{f04b}".freeze
  FOLDER = "\u{f07b}".freeze
  BUG    = "\u{f188}".freeze
  NOTE   = "\u{f001}".freeze
  GEAR   = "\u{f013}".freeze

  KEYS = %i[bg panel lines dim text accent select ok fail].freeze
  PALETTES = {
    neon: { name: 'NEON', about: 'cyan + magenta',
            colors: %w[#070b14 #0b1322 #1f6f8b #5f8aa0 #cfeffc #3ef0ff #ff3ea5 #5dffa0 #ff5d6c] },
    amber: { name: 'AMBER', about: 'cockpit amber',
             colors: %w[#0d0a06 #16110a #6b4a1a #a07a48 #ffd9a0 #ffb000 #ff6a00 #c8ff6a #ff4a3a] },
    ruby: { name: 'RUBY', about: 'dragonruby red',
            colors: %w[#0c0c10 #15151c #3a3a48 #7a7a8c #e6e6ee #e0344a #ff6b7d #6be0a0 #ff4060] },
    acid: { name: 'ACID', about: 'mono + acid green',
            colors: %w[#08090a #111315 #2a2e33 #6b7178 #d8dde2 #b6ff3b #b6ff3b #b6ff3b #ff5a4f] }
  }.freeze
  ORDER = PALETTES.keys.freeze

  class << self
    attr_reader :current, :bg, :panel, :lines, :dim, :text, :accent, :select, :ok, :fail
  end

  def self.rgb hex
    r, g, b = [1, 3, 5].map { |i| hex[i, 2].to_i(16) }
    { r: r, g: g, b: b }.freeze
  end

  def self.colors name
    KEYS.zip(PALETTES[name][:colors].map { |hex| rgb(hex) }).to_h
  end

  DEFAULT = :ruby

  # An unknown name falls back to the default.
  def self.apply name
    name = DEFAULT unless PALETTES[name]
    colors(name).each { |key, color| instance_variable_set("@#{key}", color) }
    @current = name
  end

  def self.step direction
    ORDER[(ORDER.index(@current) + direction) % ORDER.size]
  end

  apply DEFAULT
end
