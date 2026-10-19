META = "devid=mizstudio\n# a comment\ngametitle=Stealth 1-Bit\nversion=0.1\n\nicon=metadata/icon.png\n"

def test_meta_reads_key_values_and_skips_comments args, assert
  meta = Meta.parse META
  assert.equal! [meta[:gametitle], meta[:version], meta[:devid]], ['Stealth 1-Bit', '0.1', 'mizstudio']
  assert.equal! meta.size, 4
end

def test_git_info_branch_changes_and_last_commit args, assert
  git = GitInfo.parse("## main...origin/main [ahead 1]\n M app/a.rb\n?? tests/b.rb\n", "3e39606 Phase 3: hiding\n")
  assert.equal! git, { repo: true, branch: 'main', changed: 2, last: '3e39606 Phase 3: hiding' }
end

def test_git_info_before_the_first_commit args, assert
  git = GitInfo.parse("## No commits yet on master\n?? app/\n", '')
  assert.equal! [git[:branch], git[:changed], git[:last]], ['master', 1, nil]
end

def test_git_info_outside_a_repo args, assert
  assert.false! GitInfo.parse("fatal: not a git repository\n", '')[:repo]
end

def test_sdk_info_reads_version_and_tier args, assert
  info = SdkInfo.parse("* [Engine]   Version: 7.23\n* [Engine]   Tier: Standard\n")
  assert.equal! info, { version: '7.23', tier: 'Standard' }
  assert.equal! SdkInfo.label(info), 'SDK 7.23 · STANDARD'
end

def test_sdk_info_unknown_without_a_log args, assert
  assert.equal! SdkInfo.parse(''), { version: '?', tier: '?' }
end

def test_results_round_trip args, assert
  results = { 'project-1bit' => { passed: 53, failed: 33, at: 1_792_449_000 }, 'cave' => { passed: 4, failed: 0, at: 1_792_440_000 } }
  assert.equal! Results.parse(Results.dump(results)), results
end

def test_ago_in_short_units args, assert
  assert.equal! [Ago.format(30), Ago.format(300), Ago.format(7200), Ago.format(3 * 86_400), Ago.format(15 * 86_400)],
                ['just now', '5m ago', '2h ago', '3d ago', '2w ago']
end

def test_sdk_info_ignores_the_games_own_version args, assert
  assert.equal! SdkInfo.parse("- [Engine] Game Version: 0.1\n* [Engine]   Tier: Standard\n")[:version], '?'
end
