# Which SDK the launcher drives: its version (first line of CHANGELOG-CURR.txt, "* 7.23") and license tier
# (the "Tier: Standard" line any of its engine logs starts with; unknown until it has run once).
module SdkInfo
  # Shell.sdk_info output -> { version: '7.23', tier: 'Standard' }
  def self.parse text
    text.split("\n").each_with_object({ version: '?', tier: '?' }) do |line, info|
      info[:version] = line.delete_prefix('* ').strip if line.start_with?('* ') && info[:version] == '?'
      info[:tier] = line.split('Tier:', 2)[1].strip if line.include?('Tier:')
    end
  end

  def self.read
    parse Shell.run(Shell.sdk_info)
  end

  def self.label info
    "SDK #{info[:version]} · #{info[:tier].upcase}"
  end
end
