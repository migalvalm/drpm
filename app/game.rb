class Game
    attr_dr

    def tick
        @scene ||= ListScene.new
        @scene.args = args
        outputs.background_color = [20, 20, 30]
        @scene.tick
        @scene = @scene.next_scene || @scene
    end
end
