FONT = 'fonts/monogram.ttf'

require 'app/helpers/color.rb'
require 'app/controls.rb'
require 'app/shell.rb'
require 'app/projects.rb'
require 'app/test_log.rb'
require 'app/ui/buttons.rb'
require 'app/ui/text_box.rb'
require 'app/ui/text.rb'
require 'app/ui/list.rb'
require 'app/scenes/list_scene.rb'
require 'app/scenes/project_scene.rb'
require 'app/scenes/tests_scene.rb'
require 'app/scenes/new_project_scene.rb'
require 'app/game.rb'

module Main
  def boot args
    args.state = {}
  end

  def tick args
    $game ||= Game.new
    $game.args = args
    $game.tick
  end

  def reset _args
    $game = nil
  end
end