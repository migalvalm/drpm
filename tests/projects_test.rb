EDITS = "1700000300.5 ../../projects/old/app/main.rb\n1700000900.0 ../../projects/new/app/main.rb\n" \
        "1700000100.0 ../../projects/old/app/scenes/x.rb\n1700000950.0 ../../projects/old/app/game.rb\n"

def test_parse_names_the_games_sorted args, assert
  listing = "../../projects/zeta/app/main.rb\n../../projects/alpha/app/main.rb\n"
  assert.equal! Projects.parse(listing), %w[alpha zeta]
end

def test_parse_of_no_games_is_empty args, assert
  assert.equal! Projects.parse(''), []
end

def test_parse_edits_keeps_the_newest_file_per_game args, assert
  assert.equal! Projects.parse_edits(EDITS), { 'old' => 1_700_000_950.0, 'new' => 1_700_000_900.0 }
end

def test_sort_puts_the_last_edited_first args, assert
  edits = Projects.parse_edits(EDITS)
  assert.equal! Projects.sort(%w[new old never], edits), %w[old new never]
end

def test_scan_looks_only_in_the_projects_folder args, assert
  games, edits = Projects.scan
  assert.true! games.include?('project-1bit')
  assert.false! games.include?('dragonruby-template')   # templates/ isn't a game
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
