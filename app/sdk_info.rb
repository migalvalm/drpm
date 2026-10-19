# Which SDK runs the launcher: version and license tier, read from the engine's log header for this run.
module SdkInfo
  VERSION = '* [Engine]   Version: '.freeze
  TIER    = '* [Engine]   Tier: '.freeze

  # The log header's "* [Engine]   Version: 7.23" and "* [Engine]   Tier: Standard" -> { version: '7.23', tier: 'Standard' }
  def self.parse text
    text.split("\n").each_with_object({ version: '?', tier: '?' }) do |line, info|
      info[:version] = line.delete_prefix(VERSION).strip if line.start_with?(VERSION)
      info[:tier] = line.delete_prefix(TIER).strip if line.start_with?(TIER)
    end
  end

  def self.read
    gameid = Meta.parse(GTK.read_file('metadata/game_metadata.txt') || '')[:gameid] || 'launcher'
    parse Shell.run(Shell.engine_log(gameid))
  end

  def self.label info
    "SDK #{info[:version]} · #{info[:tier].upcase}"
  end
end
