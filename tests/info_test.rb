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
  info = SdkInfo.parse("* 7.23\n* [Engine]   Tier: Standard\n")
  assert.equal! info, { version: '7.23', tier: 'Standard' }
  assert.equal! SdkInfo.label(info), 'SDK 7.23 · STANDARD'
end

def test_sdk_info_unknown_without_changelog_or_logs args, assert
  assert.equal! SdkInfo.parse(''), { version: '?', tier: '?' }
end

def test_sdk_info_reads_this_sdk args, assert
  Paths.sdk = Shell.run('pwd').strip
  assert.equal! SdkInfo.read[:version], '7.23'
end

def test_results_round_trip args, assert
  results = { 'project-1bit' => { passed: 53, failed: 33, at: 1_792_449_000 }, 'cave' => { passed: 4, failed: 0, at: 1_792_440_000 } }
  assert.equal! Results.parse(Results.dump(results)), results
end

def test_ago_in_short_units args, assert
  assert.equal! [Ago.format(30), Ago.format(300), Ago.format(7200), Ago.format(3 * 86_400), Ago.format(15 * 86_400)],
                ['just now', '5m ago', '2h ago', '3d ago', '2w ago']
end

def test_settings_round_trip args, assert
  settings = { theme: :amber, sound: false, sdk: '/opt/dr sdk', projects: '/home/me/games', templates: '' }
  assert.equal! Settings.parse(Settings.dump(settings)), settings
end

def test_settings_default_to_ruby_with_sound_and_no_folders args, assert
  assert.equal! Settings.parse(''), { theme: :ruby, sound: true, sdk: '', projects: '', templates: '' }
end

def test_every_theme_has_every_colour args, assert
  Theme::ORDER.each { |name| assert.equal! Theme.colors(name).keys, Theme::KEYS }
end

def test_theme_apply_and_step args, assert
  Theme.apply :ruby
  assert.equal! [Theme.current, Theme.accent], [:ruby, Theme.rgb('#e0344a')]
  assert.equal! [Theme.step(1), Theme.step(-1)], %i[acid amber]
  Theme.apply :nope
  assert.equal! Theme.current, :ruby
end

def test_clipboard_keeps_the_first_line_trimmed args, assert
  assert.equal! Clipboard.first_line("  /home/me/dr sdk/  \nsecond line\n"), '/home/me/dr sdk/'
  assert.equal! Clipboard.first_line(''), ''
end

V_KEY = 118          # SDL keycode for v
CTRL_MOD = 64        # SDL left-Ctrl modifier bit

# Ctrl held from an earlier tick, then V pressed: the engine's own key event, as SDL sends it.
def test_clipboard_pastes_on_v_with_ctrl_held args, assert
  keyboard = $gtk.args.inputs.keyboard   # the keyboard GTK.key_down_raw updates
  GTK.ffi_misc.setclipboard "/home/me/dr sdk\nsecond line"
  keyboard.key_held.set [:control], Kernel.tick_count
  GTK.key_down_raw V_KEY, CTRL_MOD
  assert.false! keyboard.key_down.control   # why key_down.control alone never worked
  assert.equal! Clipboard.pasted(keyboard), '/home/me/dr sdk'
  keyboard.key_held.clear
  keyboard.key_down.clear
end

def test_clipboard_ignores_v_alone args, assert
  keyboard = $gtk.args.inputs.keyboard   # the keyboard GTK.key_down_raw updates
  GTK.key_down_raw V_KEY, 0
  assert.nil! Clipboard.pasted(keyboard)
  keyboard.key_down.clear
end
