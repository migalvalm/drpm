# How long ago, short: "just now", "5m ago", "2h ago", "3d ago", "6w ago".
module Ago
  STEPS = [[60, 'm'], [3600, 'h'], [86_400, 'd'], [604_800, 'w']].freeze

  def self.format seconds
    return 'just now' if seconds < 60

    size, unit = STEPS.reverse.find { |s, _| seconds >= s }
    "#{seconds.div(size)}#{unit} ago"
  end

  def self.since time
    format Time.now.to_i - time.to_i
  end
end
