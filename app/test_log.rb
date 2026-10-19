# Reads the output of DR test runs (one or more --test runs in a row): the totals, the failed tests,
# and whether the runs are over (Shell.test prints DONE at the end).
module TestLog
  PREFIX = '- [Game] '
  FAILED = '**** Test name: Object#'

  def self.summary text
    lines = text.split("\n").map { |line| line.delete_prefix(PREFIX) }
    { passed: count(lines, 'test(s) passed.'), failed: count(lines, 'test(s) failed.'),
      failures: lines.select { |line| line.start_with?(FAILED) }.map { |line| line.delete_prefix(FAILED) },
      done: lines.include?('DONE') }
  end

  # Adds up the "N test(s) ..." lines, one per run.
  def self.count lines, ending
    lines.select { |line| line.end_with?(ending) }.sum(&:to_i)
  end
end
