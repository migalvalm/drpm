# Where things are: the SDK folder (with ./dragonruby), the projects folder (each game a subfolder with app/main.rb)
# and the templates folder (optional). Absolute paths, chosen in Setup and kept by Settings.
module Paths
  class << self
    attr_accessor :sdk, :projects, :templates
  end

  # A path made safe for sh: in single quotes, with any ' inside escaped.
  def self.q path
    "'#{path.to_s.gsub("'", "'\\\\''")}'"
  end

  # ~ and ~/x -> home and home/x; a trailing / dropped.
  def self.expand text, home
    path = text.strip
    path = home + path[1, path.size] if path == '~' || path.start_with?('~/')
    path.size > 1 ? path.chomp('/') : path
  end

  # Why a folder can't be the SDK / the projects / the templates, or nil. check: what Paths.check said about it.
  def self.problem kind, path, check
    return 'type a folder (Tab completes)' if path.empty? && kind != :templates
    return nil if path.empty?
    return 'no such folder' if check.empty?
    return 'no dragonruby in this folder (the unzipped SDK has it)' if kind == :sdk && check != 'sdk'

    nil
  end

  def self.check path
    Shell.run(Shell.check(path)).strip
  end

  def self.ready?
    !sdk.to_s.empty? && !projects.to_s.empty? && check(sdk) == 'sdk' && check(projects) != ''
  end

  # Tab on a path: the longest common start of the folders that begin with what was typed.
  def self.complete text, listing
    folders = listing.split("\n").select { |line| line.end_with?('/') }
    return text if folders.empty?

    common = folders.reduce { |a, b| a[0, (0...[a.size, b.size].min).find { |i| a[i] != b[i] } || [a.size, b.size].min] }
    common.size > text.size ? common : text
  end

  def self.listing prefix
    Shell.run Shell.listing(prefix)
  end
end
