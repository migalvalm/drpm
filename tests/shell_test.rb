# Paths as Setup would leave them (spaces on purpose: every path is quoted).
def with_paths
  Paths.sdk = '/home/me/dr sdk/dragonruby-linux-amd64'
  Paths.projects = '/home/me/games'
  Paths.templates = '/home/me/templates'
end

def test_play_runs_the_game_from_the_sdk_in_the_background args, assert
  with_paths
  assert.equal! Shell.play('cave'), "(cd '/home/me/dr sdk/dragonruby-linux-amd64' && ./dragonruby '/home/me/games/cave') > /dev/null 2>&1 &"
end

def test_open_opens_the_game_folder args, assert
  with_paths
  assert.equal! Shell.open('cave'), "xdg-open '/home/me/games/cave' > /dev/null 2>&1 &"
end

def test_test_runs_each_file_hidden_into_the_sdk_log args, assert
  with_paths
  command = Shell.test('cave', %w[a_test.rb b_test.rb])
  assert.true! command.include?("SDL_VIDEODRIVER=offscreen ./dragonruby '/home/me/games/cave' --test 'tests/a_test.rb'; ")
  assert.true! command.include?('echo DONE) > tmp/launcher-tests.log 2>&1')
  assert.true! command.start_with?("(cd '/home/me/dr sdk/dragonruby-linux-amd64' && mkdir -p tmp")
end

def test_run_returns_what_the_command_printed args, assert
  assert.equal! Shell.run('echo hi'), "hi\n"
end

def test_paths_quote_for_sh args, assert
  assert.equal! Paths.q("/a b/it's"), "'/a b/it'\\''s'"
  assert.equal! Shell.run("printf %s #{Paths.q("it's a b")}"), "it's a b"
end

def test_paths_expand_home_and_trailing_slash args, assert
  assert.equal! [Paths.expand('~/x/', '/home/me'), Paths.expand('~', '/home/me'), Paths.expand(' /opt/sdk ', '/h')],
                ['/home/me/x', '/home/me', '/opt/sdk']
end

def test_paths_problems args, assert
  assert.equal! Paths.problem(:sdk, '', ''), 'type a folder (Tab completes)'
  assert.nil! Paths.problem(:templates, '', '')
  assert.equal! Paths.problem(:projects, '/nope', ''), 'no such folder'
  assert.equal! Paths.problem(:sdk, '/tmp', 'dir'), 'no dragonruby in this folder (the unzipped SDK has it)'
  assert.nil! Paths.problem(:sdk, '/opt/dr', 'sdk')
end

def test_paths_complete_to_the_common_start args, assert
  assert.equal! Paths.complete('/home/me/Pro', "/home/me/Projects/\n/home/me/Programs/\n/home/me/Profile.txt\n"), '/home/me/Pro'
  assert.equal! Paths.complete('/home/me/Proj', "/home/me/Projects/\n"), '/home/me/Projects/'
  assert.equal! Paths.complete('/x', ''), '/x'
end

def test_paths_check_finds_this_sdk args, assert
  assert.equal! Paths.check(Shell.run('pwd').strip), 'sdk'   # tests run from the SDK folder
  assert.equal! Paths.check('/no/such/folder'), ''
end

def test_mac_opens_folders_with_open_and_reads_times_with_bsd_stat args, assert
  with_paths
  assert.equal! Shell.open('cave', true), "open '/home/me/games/cave' > /dev/null 2>&1 &"
  assert.true! Shell.edits(true).include?("-exec stat -f '%m %N' {} +")
  assert.true! Shell.edits(false).include?("-exec stat -c '%Y %n' {} +")
end

def test_metadata_rename_keeps_other_lines_and_uncomments args, assert
  dir = Shell.run('mktemp -d').strip
  Shell.run "mkdir -p #{dir}/t/metadata #{dir}/g && printf '# gameid=x\\n#gametitle=Y\\nversion=0.1\\n' > #{dir}/t/metadata/game_metadata.txt"
  Paths.projects = "#{dir}/g"
  out = Shell.run Shell.create('cave', 'Cave Run', "#{dir}/t")
  meta = Shell.run "cat #{dir}/g/cave/metadata/game_metadata.txt"
  Shell.run "rm -rf #{dir}"
  assert.true! out.include?('CREATED')
  assert.equal! meta, "gameid=cave\ngametitle=Cave Run\nversion=0.1\n"
end
