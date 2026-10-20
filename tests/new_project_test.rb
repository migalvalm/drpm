def test_create_copies_the_template_names_the_game_and_inits_git args, assert
  Paths.projects = '/home/me/games'
  command = Shell.create('cave', 'Cave Run', '/home/me/templates/starter')
  assert.true! command.include?("mkdir '/home/me/games/cave' && { tar -C '/home/me/templates/starter' --exclude=./.git --exclude=./.github")
  assert.true! command.include?("-e 's/^#* *gametitle=.*/gametitle=Cave Run/' '/home/me/games/cave'/metadata/game_metadata.txt > ")
  assert.true! command.include?("&& mv '/home/me/games/cave'/metadata/game_metadata.txt.new '/home/me/games/cave'/metadata/game_metadata.txt; }; }")
  assert.true! command.end_with?("git -C '/home/me/games/cave' init -q || { rm -rf '/home/me/games/cave'; false; }; } && echo CREATED) 2>&1")
end

# Runs Shell.create for real in a scratch folder: [output, what is left in the projects folder].
def create_in_scratch template_files
  dir = Shell.run('mktemp -d').strip
  Shell.run "mkdir -p #{dir}/g #{dir}/t/app && touch #{dir}/t/app/main.rb" if template_files
  Paths.projects = "#{dir}/g"
  out = Shell.run Shell.create('cave', 'Cave', "#{dir}/t")
  left = Shell.run "ls #{dir}/g"
  Shell.run "rm -rf #{dir}"
  [out, left]
end

def test_create_from_a_template_without_metadata args, assert
  out, left = create_in_scratch true
  assert.true! out.include?('CREATED')
  assert.equal! left, "cave\n"
end

def test_create_that_fails_leaves_no_folder args, assert
  out, left = create_in_scratch false   # no template folder: the copy fails
  assert.false! out.include?('CREATED')
  assert.equal! left, ''
end

def test_templates_lists_yours_then_a_blank_game args, assert
  templates = Templates.parse("zeta/\nalpha/\nREADME.md\n", '/t', '/sdk')
  assert.equal! templates.map { |t| t[:name] }, ['alpha', 'zeta', 'none · blank game']
  assert.equal! [templates.first[:path], templates.last[:path]], ['/t/alpha', '/sdk/mygame']
end

def test_templates_with_none_of_yours_still_has_the_blank_game args, assert
  assert.equal! Templates.parse('', '', '/sdk'), [{ name: 'none · blank game', path: '/sdk/mygame' }]
end
