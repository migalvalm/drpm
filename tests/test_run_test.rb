# Two runs in a row, as Shell.test writes them: one all green, one with a failure, then DONE.
def two_runs
  ['- [Game] 3 test(s) passed.', '- [Game] **** Object#test_a', '- [Game] 0 test(s) failed.',
   '- [Game] 1 test(s) passed.', '- [Game] 1 test(s) failed.', '- [Game] **** Test name: Object#test_jump',
   'actual:', 'DONE'].join("\n")
end

def test_tests_lists_only_test_files_sorted args, assert
  assert.equal! Projects.parse_tests("sound_test.rb\nhelpers.rb\nanim_test.rb\n"), %w[anim_test.rb sound_test.rb]
end

def test_test_runs_each_file_in_turn_with_no_window_into_the_log args, assert
  runs = %w[a b].map { |f| "SDL_VIDEODRIVER=offscreen ./dragonruby ../../projects/game --test tests/#{f}_test.rb" }
  assert.equal! Shell.test('game', %w[a_test.rb b_test.rb], 'l/tmp/test.log'), "(#{runs.join('; ')}; echo DONE) > l/tmp/test.log 2>&1 &"
end

def test_summary_adds_up_every_run args, assert
  summary = TestLog.summary two_runs
  assert.equal! [summary[:passed], summary[:failed], summary[:failures]], [4, 1, ['test_jump']]
end

def test_summary_is_done_after_done args, assert
  assert.true! TestLog.summary(two_runs)[:done]
  assert.false! TestLog.summary("- [Game] 1 test(s) passed.\n")[:done]
end

def test_summary_of_an_empty_log_is_zero args, assert
  assert.equal! TestLog.summary(''), { passed: 0, failed: 0, failures: [], done: false }
end
