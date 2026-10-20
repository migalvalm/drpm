# Reads the output of DR test runs (one or more --test runs in a row): the totals, the failed tests,
# how many runs finished, and whether all are over (Shell.test prints DONE at the end).
module TestLog
  PREFIX = '- [Game] '.freeze
  FAILED = '**** Test name: Object#'.freeze
  PASSED_LINE = 'test(s) passed.'.freeze

  def self.summary text
    lines = text.split("\n").map { |line| line.delete_prefix(PREFIX) }
    { passed: count(lines, PASSED_LINE), failed: count(lines, 'test(s) failed.'),
      failures: lines.select { |line| line.start_with?(FAILED) }.map { |line| line.delete_prefix(FAILED) },
      runs: lines.count { |line| line.end_with?(PASSED_LINE) }, done: lines.include?('DONE') }
  end

  # Adds up the "N test(s) ..." lines, one per run.
  def self.count lines, ending
    lines.select { |line| line.end_with?(ending) }.sum(&:to_i)
  end
end
