module Shell
  HOME     = '../..'.freeze                     # the launcher's folder, seen from the SDK
  PROJECTS = "#{HOME}/projects".freeze 
  TEMPLATE = "#{HOME}/templates/dragonruby-template".freeze
  BACKGROUND    = '> /dev/null 2>&1 &'.freeze     
  HIDDEN   = 'SDL_VIDEODRIVER=offscreen'.freeze  # test runs draw offscreen, no window

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

  # Copies the template (without its git history and CI) to a new folder, names the game and starts a repo.
  # Prints CREATED when every step worked, else the first error.
  def self.create name, title
    dir = "#{PROJECTS}/#{name}"
    steps = ["mkdir #{dir}",
             "tar -C #{TEMPLATE} --exclude=./.git --exclude=./.github -cf - . | tar -C #{dir} -xf -",
             "sed -i -e 's/^gameid=.*/gameid=#{name}/' -e 's/^gametitle=.*/gametitle=#{title}/' #{dir}/metadata/game_metadata.txt",
             "git -C #{dir} init -q",
             'echo CREATED']
    "(#{steps.join(' && ')}) 2>&1"
  end

  def self.run command
    puts "$ #{command}"
    GTK.exec command
  end
end