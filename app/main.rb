require 'app/helpers/color.rb'
require 'app/controls.rb'
require 'app/shell.rb'
require 'app/meta.rb'
require 'app/sdk_info.rb'
require 'app/projects.rb'
require 'app/templates.rb'
require 'app/git_info.rb'
require 'app/results.rb'
require 'app/ago.rb'
require 'app/command.rb'
require 'app/test_log.rb'
require 'app/test_run.rb'
require 'app/theme.rb'
require 'app/blip.rb'
require 'app/session.rb'
require 'app/ui/hud.rb'
require 'app/ui/fx.rb'
require 'app/ui/chrome.rb'
require 'app/ui/field.rb'
require 'app/ui/command_bar.rb'
require 'app/ui/game_list.rb'
require 'app/ui/details.rb'
require 'app/ui/new_form.rb'
require 'app/scenes/boot_scene.rb'
require 'app/scenes/main_scene.rb'
require 'app/scenes/main_scene_draw.rb'
require 'app/scenes/tests_scene.rb'
require 'app/scenes/tests_scene_draw.rb'
require 'app/game.rb'

module Main
  def boot args
    args.state = {}
    DR.start_text_input   # on for good: the `:` bar and the New project form read inputs.text
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
