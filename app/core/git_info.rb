# What git says about a game: branch, how many files changed, the last commit (nil when not a repo / no commits).
module GitInfo
  NO_COMMITS = 'No commits yet on '.freeze

  # status: `git status --porcelain -b` output; log: `git log -1 --format='%h %s'` output.
  def self.parse status, log
    lines = status.split("\n")
    head = lines.first.to_s
    return { repo: false, branch: nil, changed: 0, last: nil } unless head.start_with?('## ')

    { repo: true, branch: branch(head.delete_prefix('## ')), changed: lines.size - 1, last: log.strip.empty? ? nil : log.strip }
  end

  # "main...origin/main [ahead 1]" -> main, "No commits yet on master" -> master
  def self.branch head
    return head.delete_prefix(NO_COMMITS) if head.start_with?(NO_COMMITS)

    head.split('...').first.split(' ').first
  end

  def self.for name
    parse Shell.run(Shell.git_status(name)), Shell.run(Shell.git_log(name))
  end
end
