# What the scenes share: the SDK info, the last test results (saved between runs) and the test run going on now.
class Session
  attr_reader :sdk, :results, :run

  def initialize
    Settings.load
    @sdk = SdkInfo.read
    @results = Results.load
  end

  # Starts a run unless one is going; returns the run or nil.
  def start_run name, label, files
    return nil if running?

    @run = TestRun.new(name, label, files).start
  end

  def running?
    @run && !@run.done?
  end

  # Every half second while a run goes: re-read its log; when it ends, keep the result and say so.
  def tick audio
    return unless running? && Kernel.tick_count % 30 == 0

    @run.poll
    finish audio if @run.done?
  end

  def finish audio
    s = @run.summary
    @results[@run.name] = { passed: s[:passed], failed: s[:failed], at: Time.now.to_i }
    Results.save @results
    Blip.play audio, s[:failed].zero? ? :pass : :fail
  end
end
