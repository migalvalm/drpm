# A game's metadata/game_metadata.txt as a Hash: key=value lines, comments and blanks skipped.
module Meta
  def self.parse text
    text.split("\n").each_with_object({}) do |line, meta|
      next if line.strip.empty? || line.strip.start_with?('#') || !line.include?('=')

      key, value = line.split('=', 2)
      meta[key.strip.to_sym] = value.strip
    end
  end

  def self.for name
    parse Shell.run(Shell.metadata(name))
  end
end
