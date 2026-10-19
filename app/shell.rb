# The shell commands the launcher runs. The launcher's rule: the SDK lives in launcher/sdk/<sdk>/, where DR runs
# every command, so the launcher's folder is ../.. and games are only looked for in launcher/projects/.
module Shell
  HOME       = '../..'.freeze                                # the launcher's folder, seen from the SDK
  PROJECTS   = "#{HOME}/projects".freeze
  TEMPLATES  = "#{HOME}/templates".freeze
  MYGAME     = 'mygame'.freeze                               # the SDK's own starter, always there
  BACKGROUND = '> /dev/null 2>&1 &'.freeze                   # so the launcher keeps drawing
  HIDDEN     = 'SDL_VIDEODRIVER=offscreen'.freeze            # test runs draw offscreen, no window

  def self.play name
    "./dragonruby #{PROJECTS}/#{name} #{BACKGROUND}"
  end

  def self.open name
    "xdg-open #{PROJECTS}/#{name} #{BACKGROUND}"
  end

  # Runs the test files one after another, with no window, into log (a path from the SDK folder), then prints DONE.
  def self.test name, files, log
    runs = files.map { |file| "#{HIDDEN} ./dragonruby #{PROJECTS}/#{name} --test tests/#{file}" }.join('; ')
    "(#{runs}; echo DONE) > #{log} 2>&1 &"
  end

  # Copies a template (a folder path from the SDK, without its git history and CI) to a new folder, names the game
  # (also un-commenting `# gameid=` lines, as in the SDK's mygame) and starts a repo. Prints CREATED when every step
  # worked, else the first error.
  def self.create name, title, template
    dir = "#{PROJECTS}/#{name}"
    steps = ["mkdir #{dir}",
             "tar -C #{template} --exclude=./.git --exclude=./.github -cf - . | tar -C #{dir} -xf -",
             "sed -i -e 's/^#\\? \\?gameid=.*/gameid=#{name}/' -e 's/^#\\? \\?gametitle=.*/gametitle=#{title}/' #{dir}/metadata/game_metadata.txt",
             "git -C #{dir} init -q",
             'echo CREATED']
    "(#{steps.join(' && ')}) 2>&1"
  end

  # Every file in every game's app/, with its change time: "<seconds> <path>" per line.
  def self.edits
    "find #{PROJECTS}/*/app -type f -printf '%T@ %p\\n' 2>/dev/null"
  end

  def self.metadata name
    "cat #{PROJECTS}/#{name}/metadata/game_metadata.txt 2>/dev/null"
  end

  def self.git_status name
    "git -C #{PROJECTS}/#{name} status --porcelain -b 2>&1"
  end

  def self.git_log name, count = 1
    "git -C #{PROJECTS}/#{name} log -#{count} --format='%h %s' 2>/dev/null"
  end

  # The top of the engine's log for this run (DR rewrites logs/<gameid>.log in the SDK each start, version and tier first).
  def self.engine_log gameid
    "head -8 logs/#{gameid}.log 2>/dev/null"
  end

  # Runs a command (logged to the console) and returns what it printed.
  def self.run command
    puts "$ #{command}"
    GTK.exec command
  end
end
