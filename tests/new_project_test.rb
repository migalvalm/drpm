def test_create_copies_the_template_names_the_game_and_inits_git args, assert
  command = Shell.create('cave', 'Cave Run')
  assert.true! command.include?('mkdir ../../projects/cave && tar -C ../../templates/dragonruby-template --exclude=./.git --exclude=./.github')
  assert.true! command.include?("-e 's/^gameid=.*/gameid=cave/' -e 's/^gametitle=.*/gametitle=Cave Run/' ../../projects/cave/metadata/game_metadata.txt")
  assert.true! command.end_with?('git -C ../../projects/cave init -q && echo CREATED) 2>&1')
end

def test_problem_with_a_taken_name args, assert
  assert.equal! Projects.problem('project-1bit', %w[project-1bit]), 'project-1bit already exists'
  assert.nil! Projects.problem('cave', %w[project-1bit])
end

def test_title_for_a_folder_name args, assert
  assert.equal! Projects.title_for('cave_run-2'), 'Cave Run 2'
end
