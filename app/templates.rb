# What New project can copy: every folder in the templates folder (Paths.templates, optional), then
# "none · blank game", for no template: the SDK's own mygame/ (every SDK ships it), the smallest game that runs.
# Each is { name:, path: } with an absolute path.
module Templates
  NONE = 'none · blank game'.freeze

  # From `ls -1p` of the templates folder (folders end in /).
  def self.parse listing, templates = Paths.templates, sdk = Paths.sdk
    yours = listing.split("\n").select { |name| name.end_with?('/') }.map { |name| name.chomp('/') }.sort
    yours.map { |name| { name: name, path: "#{templates}/#{name}" } } + [{ name: NONE, path: "#{sdk}/#{Shell::MYGAME}" }]
  end

  def self.list
    parse Paths.templates.to_s.empty? ? '' : Shell.run(Shell.folders(Paths.templates))
  end
end
