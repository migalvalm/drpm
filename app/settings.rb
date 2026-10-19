# The launcher's own options, kept between runs in state/settings.txt as key=value lines: theme and sound.
module Settings
  FILE = 'state/settings.txt'.freeze

  def self.parse text
    pairs = text.split("\n").map { |line| line.split('=', 2) }.select { |_key, value| value }.to_h
    { theme: (pairs['theme'] || 'neon').strip.to_sym, sound: pairs['sound']&.strip != 'off' }
  end

  def self.dump settings
    "theme=#{settings[:theme]}\nsound=#{settings[:sound] ? 'on' : 'off'}\n"
  end

  # Reads the file and applies it: the palette and the sound.
  def self.load
    settings = parse(GTK.read_file(FILE) || '')
    Theme.apply settings[:theme]
    Blip.muted = !settings[:sound]
  end

  # Writes what is in use now.
  def self.save
    GTK.write_file FILE, dump(theme: Theme.current, sound: !Blip.muted)
  end
end
