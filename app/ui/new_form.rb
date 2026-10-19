# New project in the right pane: folder name, title (suggested from the folder), template (←/→ to pick).
# Enter goes to the next field and creates on the last one; Esc cancels. Plain class, no args.
class NewForm
  NAME_CHARS  = 'abcdefghijklmnopqrstuvwxyz0123456789_-'.freeze
  TITLE_CHARS = "#{NAME_CHARS}ABCDEFGHIJKLMNOPQRSTUVWXYZ ".freeze
  FIELDS = %w[FOLDER TITLE TEMPLATE].freeze

  attr_reader :problem

  def initialize templates
    @templates = templates
    @folder = Field.new('', 24, NAME_CHARS)
    @title = Field.new('', 32, TITLE_CHARS)
    @template = 0
    @focus = 0
  end

  # Returns [:create, folder, title, template path], :cancel, or nil.
  def update chars, keys
    return :cancel if keys.escape

    [@folder, @title][@focus]&.update(chars, keys)
    pick keys if @focus == 2
    return unless keys.enter || keys.kp_enter || keys.tab

    advance
  end

  def pick keys
    step = (keys.right ? 1 : 0) - (keys.left ? 1 : 0)
    @template = (@template + step) % @templates.size
  end

  # Next field, checking the folder name first; on the last field, the result to create.
  def advance
    if @focus.zero?
      @problem = Projects.problem(@folder.text, Projects.taken)
      return if @problem

      @title.text = Projects.title_for(@folder.text) if @title.text.empty?
    end
    return [:create, @folder.text, @title.text, @templates[@template][:path]] if @focus == 2

    @focus += 1
    nil
  end

  def fail message
    @problem = message
  end

  def draw x, y, since
    out = [Hud.text(x + 28, y + 528, Hud.reveal('NEW PROJECT', since, 2), size: 40, color: Theme::SELECT, font: Theme::EXTRABOLD),
           Hud.text(x + 28, y + 484, 'from a template into launcher/projects/', size: 17, color: Theme::DIM, font: Theme::LIGHT)]
    FIELDS.each_with_index { |label, i| out.concat(row(label, i, x, y + 400 - i * 76)) }
    out << Hud.text(x + 28, y + 150, @problem, size: 18, color: Theme::FAIL) if @problem
    out << Hud.text(x + 28, y + 41, 'ENTER next / create   TAB next   ←/→ template   ESC cancel', size: 16, color: Theme::DIM)
  end

  def row label, i, x, y
    lit = i == @focus
    out = [Hud.text(x + 28, y + 20, label, size: 18, color: lit ? Theme::ACCENT : Theme::DIM, font: Theme::BOLD)]
    return out.concat([@folder, @title][i].draw(x + 200, y, lit)) if i < 2

    name = @templates[@template][:name]
    out << Hud.text(x + 200, y + 20, lit ? "◂ #{name} ▸" : name, size: 22, color: lit ? Theme::TEXT : Theme::DIM)
  end
end
