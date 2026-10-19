# A game's tests, full screen: the files on the left (ALL TESTS first), the run on the right. A run goes on
# in the background if you leave; the main screen shows its progress. Esc goes back.
class TestsScene
  attr_dr
  attr_reader :next_scene

  # file: a test file to start at once (from `:test game file`).
  def initialize session, name, file = nil
    @session, @name = session, name
    @files = Projects.tests(name)
    @entries = [TestRun::ALL] + @files
    @index = 0
    @opened = Kernel.tick_count
    start file if file
  end

  def tick
    keys = Controls.down(inputs)
    return back if keys[:escape]

    move((keys[:down] ? 1 : 0) - (keys[:up] ? 1 : 0))
    click
    start @entries[@index] if keys[:enter]
    draw
  end

  def back
    Blip.play audio, :back
    @next_scene = MainScene.new(@session, @name)
  end

  def move step
    return if step.zero?

    @index = (@index + step).clamp(0, @entries.size - 1)
    Blip.play audio, :move
  end

  # A click on a file selects it; a click on the selected one runs it.
  def click
    return unless inputs.mouse.click

    hit = GameList.hit(inputs.mouse, @entries.size, GameList.offset(@index, @entries.size))
    return unless hit

    hit == @index ? start(@entries[@index]) : move(hit - @index)
  end

  def start entry
    files = entry == TestRun::ALL ? @files : [entry]
    return @note = 'another run is going · wait for it to finish' unless @session.start_run(@name, entry, files)

    @note = nil
    Blip.play audio, :select
  end

  def run
    @session.run if @session.run&.name == @name
  end
end
