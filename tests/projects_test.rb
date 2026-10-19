EDITS = "1700000300.5 /g/old/app/main.rb\n1700000900.0 /g/new/app/main.rb\n" \
        "1700000100.0 /g/old/app/scenes/x.rb\n1700000950.0 /g/old/app/game.rb\n"

def test_parse_names_the_games_sorted args, assert
  assert.equal! Projects.parse("/g/zeta/app/main.rb\n/g/alpha/app/main.rb\n", '/g'), %w[alpha zeta]
end

def test_parse_of_no_games_is_empty args, assert
  assert.equal! Projects.parse('', '/g'), []
end

def test_parse_hides_mygame_when_the_projects_are_the_sdk args, assert
  Paths.sdk = '/opt/sdk'
  assert.equal! Projects.parse("/opt/sdk/mygame/app/main.rb\n/opt/sdk/cave/app/main.rb\n", '/opt/sdk'), ['cave']
end

def test_parse_edits_keeps_the_newest_file_per_game args, assert
  assert.equal! Projects.parse_edits(EDITS, '/g'), { 'old' => 1_700_000_950.0, 'new' => 1_700_000_900.0 }
end

def test_sort_puts_the_last_edited_first args, assert
  assert.equal! Projects.sort(%w[new old never], Projects.parse_edits(EDITS, '/g')), %w[old new never]
end

def test_scan_finds_the_games_in_the_projects_folder args, assert
  Paths.sdk = Shell.run('pwd').strip
  Paths.projects = Shell.run('cd ../../projects && pwd').strip
  games, edits = Projects.scan
  assert.true! games.include?('project-1bit')
  assert.true! edits['project-1bit'].positive?
end

def test_problem_with_an_empty_or_taken_name args, assert
  assert.equal! Projects.problem('', []), 'folder name is empty'
  assert.equal! Projects.problem('project-1bit', %w[project-1bit]), 'project-1bit already exists'
  assert.nil! Projects.problem('cave', %w[project-1bit])
end

def test_title_for_a_folder_name args, assert
  assert.equal! Projects.title_for('cave_run-2'), 'Cave Run 2'
end
