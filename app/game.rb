# Owns the session and the current scene; switches scenes at the end of the tick.
# Scene contract: `tick`, `next_scene` (nil = stay). Scenes take the session.
class Game
  attr_dr

  def tick
    @session ||= Session.new
    @scene ||= BootScene.new(@session)
    @scene.args = args
    outputs.background_color = [Theme.bg[:r], Theme.bg[:g], Theme.bg[:b]]
    @session.tick audio
    Pointer.start inputs.mouse
    @scene.tick
    Pointer.finish
    @scene = @scene.next_scene || @scene
  end
end
