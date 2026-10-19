def test_create_copies_the_template_names_the_game_and_inits_git args, assert
  command = Shell.create('cave', 'Cave Run', '../../templates/dragonruby-template')
  assert.true! command.include?('mkdir ../../projects/cave && tar -C ../../templates/dragonruby-template --exclude=./.git --exclude=./.github')
  assert.true! command.include?("-e 's/^#\\? \\?gametitle=.*/gametitle=Cave Run/' ../../projects/cave/metadata/game_metadata.txt")
  assert.true! command.end_with?('git -C ../../projects/cave init -q && echo CREATED) 2>&1')
end

def test_templates_lists_yours_then_the_sdk_mygame args, assert
  templates = Templates.parse("zeta\nalpha\nREADME.md\n")
  assert.equal! templates.map { |t| t[:name] }, ['alpha', 'zeta', 'mygame (sdk)']
  assert.equal! templates.first[:path], '../../templates/alpha'
  assert.equal! templates.last[:path], 'mygame'
end

def test_templates_with_none_of_yours_still_has_mygame args, assert
  assert.equal! Templates.parse(''), [Templates::SDK]
end
