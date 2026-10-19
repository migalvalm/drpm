class ListScene
    attr_dr
    attr_reader :next_scene
    
    TITLE = 'DragonRuby Project Manager'.freeze
    NEW  = '+ New project'.freeze
    NONE = 'No games in launcher/projects'.freeze

    def initialize
        @games = Projects.scan
        @buttons = List.buttons(@games + [NEW], 450, 400)
    end

    def tick
        outputs.labels << Text.label(350, 500, TITLE, size_px: 48)
        outputs.labels << Text.label(60, 40, NONE, Text::GREY.merge(size_px: 22)) if @games.empty?
        button = Buttons.draw(outputs, inputs.mouse, @buttons, Controls.down(inputs))
        return unless button

        @next_scene = button[:value] == NEW ? NewProjectScene.new : ProjectScene.new(button[:value])
    end
end