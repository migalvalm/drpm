# One test run in the background: which game, which files, and its log read so far.
# Only one at a time; Session polls it every half second wherever you are.
class TestRun
  ALL = 'ALL TESTS'.freeze

  attr_reader :name, :label, :files, :summary

  def initialize name, label, files
    @name, @label, @files = name, label, files
    @summary = TestLog.summary('')
  end

  def start
    Shell.run Shell.clear_test_log
    Shell.run Shell.test(@name, @files)
    self
  end

  def poll
    @summary = TestLog.summary(Shell.run(Shell.test_log))
  end

  def done?
    @summary[:done]
  end

  def progress
    return 1.0 if done?

    @summary[:runs].fdiv(@files.size).clamp(0, 1)
  end
end
