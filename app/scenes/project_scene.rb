class ProjectScene
  attr_dr
  attr_reader :next_scene

  ACTIONS = [
    { text: 'Play', action: :play }, 
    { text: 'Tests', action: :tests },
    { text: 'Open folder', action: :open },
    { text: 'Back', action: :back }
  ].freeze

  def initialize name, note = nil
    @name, @note = name, note
    @buttons = ACTIONS.each_with_index.map { |b, i| { x: 60, y: 500 - 70 * i, w: 300, h: 56 }.merge(b) }
  end

  def tick
    keys = Controls.down(inputs)
    outputs.labels << Text.label(60, 660, @name, size_px: 48)
    outputs.labels << Text.label(60, 600, @note, Text::GREY) if @note
    button = Buttons.draw(outputs, inputs.mouse, @buttons, keys)
    return @next_scene = ListScene.new if keys[:escape]

    choose button if button
  end

  # What an action button does.
  def choose button
    case button[:action]
    when :play
      Shell.run Shell.play(@name)
      @note = "Started #{@name}"
    when :tests then @next_scene = TestsScene.new(@name)
    when :open then Shell.run Shell.open(@name)
    when :back then @next_scene = ListScene.new
    end
  end
end