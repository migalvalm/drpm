GAMES = %w[project-1bit cave_run].freeze

def test_command_parses_name_and_args args, assert
  assert.equal! Command.parse('test project-1bit vision_test.rb'), { name: :test, args: %w[project-1bit vision_test.rb] }
  assert.equal! Command.parse('  play cave_run '), { name: :play, args: ['cave_run'] }
end

def test_command_new_keeps_the_title_whole args, assert
  assert.equal! Command.parse('new cave_run "Cave Run"'), { name: :new, args: ['cave_run', 'Cave Run'] }
  assert.equal! Command.parse('new cave_run'), { name: :new, args: ['cave_run'] }
end

def test_command_unknown_and_empty args, assert
  assert.equal! Command.parse('fly away'), { name: :unknown, args: ['fly'] }
  assert.equal! Command.parse(''), { name: :none, args: [] }
end

def test_complete_a_command_then_a_game args, assert
  assert.equal! Command.complete('pl', GAMES), 'play '
  assert.equal! Command.complete('play pro', GAMES), 'play project-1bit'
  assert.equal! Command.complete('git st', GAMES), 'git status'
end

def test_complete_leaves_what_matches_nothing args, assert
  assert.equal! Command.complete('play zzz', GAMES), 'play zzz'
end

def test_complete_a_theme_name args, assert
  assert.equal! Command.complete('theme am', GAMES), 'theme amber'
  assert.equal! Command.parse('theme acid'), { name: :theme, args: ['acid'] }
end
