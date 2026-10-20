# New project in the right pane: folder name, title (suggested from the folder), and the template, listed in full.
class NewForm
  FIELDS = %w[FOLDER TITLE TEMPLATE].freeze
  ITEM = 32   # template list row height

  # template: which one starts selected (from the + NEW PROJECT card).
  def initialize templates, template = 0
    @templates = templates
    @folder = Field.new('', 24, Projects::NAME_CHARS)
    @title = Field.new('', 32, Projects::TITLE_CHARS)
    @template = template.clamp(0, templates.size - 1)
    @focus = 0
  end

  # Returns [:create, folder, title, template path], :cancel, or nil.
  def update chars, keys
    return :cancel if keys.escape

    [@folder, @title][@focus]&.update(chars, keys)
    pick((keys.right ? 1 : 0) - (keys.left ? 1 : 0)) if @focus == 2
    @focus -= 1 if keys.up && @focus.positive?
    return unless keys.enter || keys.kp_enter || keys.tab || (keys.down && @focus < 2)

    advance
  end

  def pick step
    @template = (@template + step) % @templates.size
  end

  # Next field, checking the folder name first; on the last field, the result to create.
  def advance
    return unless folder_ok? || @focus.positive?
    return [:create, @folder.text, @title.text, @templates[@template][:path]] if @focus == 2

    @focus += 1
    nil
  end

  # Checks the folder name (and suggests a title from it); false, with the problem shown, if it can't be used.
  def folder_ok?
    @problem = Projects.problem(@folder.text, Projects.taken)
    @title.text = Projects.title_for(@folder.text) if !@problem && @title.text.empty?
    @problem.nil?
  end

  def fail message
    @problem = message
  end

  # A click: on a template picks it (any time, the fields stay as they are); on a field row focuses it
  # (leaving FOLDER for TITLE checks the name first).
  def click mouse, x, y
    hit = (0...@templates.size).find { |i| mouse.inside_rect?(template_rect(x, y, i)) }
    return @template = hit if hit

    row = (0..1).find { |i| mouse.inside_rect?(x: x + 20, y: field_y(y, i) - 6, w: 760, h: 52) }
    @focus = row if row && (row.zero? || folder_ok?)
  end

  def field_y y, index
    y + 400 - index * 76
  end

  def template_rect x, y, index
    { x: x + 196, y: field_y(y, 2) + 6 - index * ITEM, w: 560, h: ITEM - 4 }
  end

  # Also heads the + NEW PROJECT card.
  def self.heading x, y, since
    [Hud.text(x + 28, y + 528, Hud.reveal('NEW PROJECT', since, 2), size: 40, color: Theme.select, font: Theme::EXTRABOLD),
     Hud.text(x + 28, y + 484, 'a copy of a template, in your projects folder', size: 17, color: Theme.dim, font: Theme::LIGHT)]
  end

  def draw x, y, since
    out = NewForm.heading(x, y, since)
    FIELDS.each_with_index { |label, i| out << Hud.text(x + 28, field_y(y, i) + 20, label, size: 18, color: i == @focus ? Theme.accent : Theme.dim, font: Theme::BOLD) }
    out.concat(@folder.draw(x + 200, field_y(y, 0), @focus.zero?))
    out.concat(@title.draw(x + 200, field_y(y, 1), @focus == 1))
    out.concat(templates(x, y))
    out << Hud.text(x + 28, y + 96, @problem, size: 18, color: Theme.fail) if @problem
    out << Hud.text(x + 28, y + 41, 'ENTER next / create   ↑↓ fields   ←/→ or click a template   ESC cancel', size: 16, color: Theme.dim)
  end

  # Every template, the chosen one filled (●) and lit; brighter while TEMPLATE has the focus.
  def templates x, y
    @templates.each_with_index.flat_map do |t, i|
      r = template_rect(x, y, i)
      lit = i == @template
      hover = Pointer.over?(r)
      color = if lit then (@focus == 2 ? Theme.select : Theme.text)
              elsif hover then Theme.accent
              else Theme.dim
              end
      out = [Hud.text(r.x + 4, r.y + r.h / 2, "#{lit ? '●' : '○'} #{t[:name]}", size: 20, color: color, font: lit ? Theme::BOLD : Theme::REGULAR)]
      out.unshift(Hud.rect(r.x, r.y, r.w, r.h, Theme.select, 40)) if lit && @focus == 2
      out.unshift(Hud.rect(r.x, r.y, r.w, r.h, Theme.accent, 22)) if hover && !(lit && @focus == 2)
      out
    end
  end
end
