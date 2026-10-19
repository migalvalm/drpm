def test_play_runs_the_project_by_path_in_the_background args, assert
  assert.equal! Shell.play('project-1bit'), './dragonruby ../../projects/project-1bit > /dev/null 2>&1 &'
end

def test_open_opens_the_project_folder args, assert
  assert.equal! Shell.open('project-1bit'), 'xdg-open ../../projects/project-1bit > /dev/null 2>&1 &'
end

def test_run_returns_what_the_command_printed args, assert
  assert.equal! Shell.run('echo hi'), "hi\n"
end
