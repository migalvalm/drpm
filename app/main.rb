require 'app/system/controls.rb'
require 'app/system/paths.rb'
require 'app/system/shell.rb'
require 'app/core/meta.rb'
require 'app/core/sdk_info.rb'
require 'app/core/projects.rb'
require 'app/core/templates.rb'
require 'app/core/git_info.rb'
require 'app/system/results.rb'
require 'app/core/ago.rb'
require 'app/core/command.rb'
require 'app/core/test_log.rb'
require 'app/core/test_run.rb'
require 'app/ui/theme.rb'
require 'app/system/blip.rb'
require 'app/system/clipboard.rb'
require 'app/system/settings.rb'
require 'app/core/session.rb'
require 'app/ui/hud.rb'
require 'app/ui/pointer.rb'
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
require 'app/scenes/settings_scene.rb'
require 'app/scenes/setup_scene.rb'
require 'app/scenes/setup_scene_draw.rb'
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
