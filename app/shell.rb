# The shell commands the launcher runs. Every path comes from Paths (absolute, quoted), so the launcher works the
# same run from source inside an SDK or as a build anywhere. dragonruby runs from the SDK folder (cd first).
# POSIX sh for Linux and macOS; the two differences (opening a folder, file times) switch on mac.
module Shell
  BACKGROUND = '> /dev/null 2>&1 &'.freeze   # so the launcher keeps drawing
  HIDDEN     = 'SDL_VIDEODRIVER=offscreen'.freeze   # test runs draw offscreen, no window
  MYGAME     = 'mygame'.freeze   # the SDK's own starter, always there
  TEST_LOG   = 'tmp/launcher-tests.log'.freeze   # in the SDK folder, read back with cat

  def self.mac?
    DR.platform?(:macos)
  end

  def self.game name
    Paths.q "#{Paths.projects}/#{name}"
  end

  def self.in_sdk command
    "cd #{Paths.q Paths.sdk} && #{command}"
  end

  def self.play name
    "(#{in_sdk "./dragonruby #{game name}"}) #{BACKGROUND}"
  end

  def self.open name, mac = mac?
    "#{mac ? 'open' : 'xdg-open'} #{game name} #{BACKGROUND}"
  end

  # Runs the test files one after another, with no window, into the SDK's tmp/launcher-tests.log, then prints DONE.
  def self.test name, files
    runs = files.map { |file| "#{HIDDEN} ./dragonruby #{game name} --test tests/#{file}" }.join('; ')
    "(#{in_sdk "mkdir -p tmp && (#{runs}; echo DONE) > #{TEST_LOG} 2>&1"}) #{BACKGROUND}"
  end

  def self.test_log
    "cat #{Paths.q "#{Paths.sdk}/#{TEST_LOG}"} 2>/dev/null"
  end

  def self.clear_test_log
    "rm -f #{Paths.q "#{Paths.sdk}/#{TEST_LOG}"}"
  end

  # Copies a template folder (without its git history and CI) to a new game, names it (also un-commenting
  # `# gameid=` lines, as in the SDK's mygame) and starts a repo. Prints CREATED when every step worked, else the first error.
  def self.create name, title, template
    dir = game name
    meta = "#{dir}/metadata/game_metadata.txt"
    steps = ["mkdir #{dir}",
             "tar -C #{Paths.q template} --exclude=./.git --exclude=./.github -cf - . | tar -C #{dir} -xf -",
             "sed -e 's/^#* *gameid=.*/gameid=#{name}/' -e 's/^#* *gametitle=.*/gametitle=#{title}/' #{meta} > #{meta}.new",
             "mv #{meta}.new #{meta}",
             "git -C #{dir} init -q",
             'echo CREATED']
    "(#{steps.join(' && ')}) 2>&1"
  end

  def self.games
    "ls -d #{Paths.q Paths.projects}/*/app/main.rb 2>/dev/null"
  end

  # Every file in every game's app/, with its change time: "<seconds> <path>" per line.
  def self.edits mac = mac?
    "find #{Paths.q Paths.projects}/*/app -type f -exec stat #{mac ? "-f '%m %N'" : "-c '%Y %n'"} {} + 2>/dev/null"
  end

  def self.tests name
    "ls #{game name}/tests 2>/dev/null"
  end

  def self.folders path
    "ls -1p #{Paths.q path} 2>/dev/null"
  end

  def self.metadata name
    "cat #{game name}/metadata/game_metadata.txt 2>/dev/null"
  end

  def self.git_status name, short = false
    short ? "git -C #{game name} status --short --branch 2>&1" : "git -C #{game name} status --porcelain -b 2>&1"
  end

  def self.git_log name, count = 1
    "git -C #{game name} log -#{count} --format='%h %s' 2>/dev/null"
  end

  # The SDK's version (first line of its changelog) and license tier (from the newest engine log that has it).
  def self.sdk_info
    sdk = Paths.q Paths.sdk
    "head -1 #{sdk}/CHANGELOG-CURR.txt 2>/dev/null; grep -h -m1 -E '^\\* \\[Engine\\] +Tier:' $(ls -t #{sdk}/logs/*.log 2>/dev/null) 2>/dev/null | head -1"
  end

  def self.home
    run('echo $HOME').strip
  end

  # Runs a command (logged to the console) and returns what it printed.
  def self.run command
    puts "$ #{command}"
    GTK.exec command
  end
end
