class NewProjectScene
  attr_dr
  attr_reader :next_scene

  NAME_CHARS  = 'abcdefghijklmnopqrstuvwxyz0123456789_-'
  TITLE_CHARS = "#{NAME_CHARS}ABCDEFGHIJKLMNOPQRSTUVWXYZ "

  def initialize
    @box = TextBox.new('', 24, NAME_CHARS)
  end

  def tick
    outputs.labels << Text.label(60, 660, 'New project', size_px: 48)
    outputs.labels << Text.label(640, 240, @problem, Text::RED.merge(anchor_x: 0.5)) if @problem
    @box.draw(outputs, 640, 400, @name ? 'Game title' : 'Folder name')
    step @box.update(inputs.text, inputs.keyboard.key_down)
  end

  def step result
    return @next_scene = ListScene.new if result == :cancel
    return unless result == :done

    @name ? create : take_name
  end

  def take_name
    @problem = Projects.duplicated(@box.text)
    return @box = TextBox.new(@box.text, 24, NAME_CHARS) if @problem

    @name = @box.text
    @box = TextBox.new(Projects.title_for(@name), 32, TITLE_CHARS)
  end

  def create
    out = Shell.run Shell.create(@name, @box.text)
    return @next_scene = ProjectScene.new(@name, 'Created from the template') if out.include?('CREATED')

    @problem = out.split("\n").first
    @box = TextBox.new(@box.text, 32, TITLE_CHARS)
  end
end
