class TestsScene
  attr_dr
  attr_reader :next_scene

  ALL = 'All tests'.freeze
  LOG = 'tmp/test.log'.freeze

  def initialize name
    @name = name
    @files = Projects.tests(name)
    @buttons = List.buttons([ALL] + @files, 60, 580)
  end

  def tick
    keys = Controls.down(inputs)
    outputs.labels << Text.label(60, 660, "#{@name} tests", size_px: 48)
    button = Buttons.draw(outputs, inputs.mouse, @buttons, keys)
    return @next_scene = ProjectScene.new(@name) if keys[:escape]

    run button[:value] if button
    draw_summary if @running
  end

  def run value
    GTK.write_file LOG, '' 
    Shell.run Shell.test(@name, value == ALL ? @files : [value], "#{Shell::HOME}/#{LOG}")
    @running = value
  end

  def draw_summary
    @summary = TestLog.summary(GTK.read_file(LOG) || '') if !@summary || Kernel.tick_count % 30 == 0

    x = 880
    outputs.labels << Text.label(x, 580, @running)
    outputs.labels << Text.label(x, 534, @summary[:done] ? 'Done' : 'Running...', Text::GREY)
    outputs.labels << Text.label(x, 488, "#{@summary[:passed]} passed", Text::GREEN)
    outputs.labels << Text.label(x, 442, "#{@summary[:failed]} failed", @summary[:failed].zero? ? Text::GREY : Text::RED)

    @summary[:failures].first(10).each_with_index do |test, i|
      outputs.labels << Text.label(x, 400 - 28 * i, test.delete_prefix('test_')[0, 30], Text::RED.merge(size_px: 22))
    end
  end
end
