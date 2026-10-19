# One test run in the background: which game, which files, and its log read so far.
# Only one at a time; Session polls it every half second wherever you are.
class TestRun
  LOG = 'tmp/test.log'.freeze   # in the launcher's folder
  ALL = 'ALL TESTS'.freeze

  attr_reader :name, :label, :files, :summary

  def initialize name, label, files
    @name, @label, @files = name, label, files
    @summary = TestLog.summary('')
  end

  def start
    GTK.write_file LOG, ''   # makes tmp/ and clears the last run
    Shell.run Shell.test(@name, @files, "#{Shell::HOME}/#{LOG}")
    self
  end

  def poll
    @summary = TestLog.summary(GTK.read_file(LOG) || '')
  end

  def done?
    @summary[:done]
  end

  # 0.0 .. 1.0 by finished files.
  def progress
    return 1.0 if done?

    @summary[:runs].fdiv(@files.size).clamp(0, 1)
  end
end
