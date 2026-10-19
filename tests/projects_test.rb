def test_parse_names_the_games_sorted args, assert
  listing = "../../projects/zeta/app/main.rb\n../../projects/alpha/app/main.rb\n"
  assert.equal! Projects.parse(listing), %w[alpha zeta]
end

def test_parse_of_no_games_is_empty args, assert
  assert.equal! Projects.parse(''), []
end

def test_scan_looks_only_in_the_projects_folder args, assert
  games = Projects.scan
  assert.true! games.include?('project-1bit')
  assert.false! games.include?('dragonruby-template')   # templates/ isn't a game
end
