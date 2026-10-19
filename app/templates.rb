# What New project can copy: every folder in launcher/templates/ (yours, not in the launcher's repo),
# then the SDK's own mygame/, which every SDK ships, so there is always one.
module Templates
  SDK = { name: 'mygame (sdk)', path: Shell::MYGAME }.freeze

  # From `ls` of launcher/templates/.
  def self.parse listing
    listing.split("\n").reject { |name| name.include?('.') }.sort
           .map { |name| { name: name, path: "#{Shell::TEMPLATES}/#{name}" } } + [SDK]
  end

  def self.list
    parse Shell.run("ls #{Shell::TEMPLATES} 2>/dev/null")
  end
end
