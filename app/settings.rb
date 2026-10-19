# The launcher's own options, kept between runs in state/settings.txt as key=value lines: the three folders,
# the theme and the sound. (A build keeps state/ in the player's data folder; GTK.write_file picks it.)
module Settings
  FILE = 'state/settings.txt'.freeze
  FOLDERS = %i[sdk projects templates].freeze

  def self.parse text
    pairs = text.split("\n").map { |line| line.split('=', 2) }.select { |_key, value| value }.to_h
    { theme: (pairs['theme'] || 'ruby').strip.to_sym, sound: pairs['sound']&.strip != 'off',
      sdk: pairs['sdk'].to_s.strip, projects: pairs['projects'].to_s.strip, templates: pairs['templates'].to_s.strip }
  end

  def self.dump settings
    lines = FOLDERS.map { |key| "#{key}=#{settings[key]}" }
    (lines + ["theme=#{settings[:theme]}", "sound=#{settings[:sound] ? 'on' : 'off'}"]).join("\n") + "\n"
  end

  # Reads the file and applies it: folders, palette, sound.
  def self.load
    settings = parse(GTK.read_file(FILE) || '')
    FOLDERS.each { |key| Paths.send("#{key}=", settings[key]) }
    Theme.apply settings[:theme]
    Blip.muted = !settings[:sound]
  end

  # Writes what is in use now.
  def self.save
    GTK.write_file FILE, dump({ theme: Theme.current, sound: !Blip.muted, sdk: Paths.sdk, projects: Paths.projects, templates: Paths.templates })
  end
end
