# What New project can copy: every folder in the templates folder (Paths.templates, optional), then the SDK's
# own mygame/, which every SDK ships, so there is always one. Each is { name:, path: } with an absolute path.
module Templates
  # From `ls -1p` of the templates folder (folders end in /).
  def self.parse listing, templates = Paths.templates, sdk = Paths.sdk
    yours = listing.split("\n").select { |name| name.end_with?('/') }.map { |name| name.chomp('/') }.sort
    yours.map { |name| { name: name, path: "#{templates}/#{name}" } } + [{ name: 'mygame (sdk)', path: "#{sdk}/#{Shell::MYGAME}" }]
  end

  def self.list
    parse Paths.templates.to_s.empty? ? '' : Shell.run(Shell.folders(Paths.templates))
  end
end
