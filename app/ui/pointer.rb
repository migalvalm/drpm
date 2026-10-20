# The mouse pointer: a hand over things you can click, an I-beam over text fields, the arrow elsewhere.
# Drawing code asks Pointer.over?(rect) (true while the mouse is on it, and lit up by the caller);
# Game starts and finishes each frame, and the system cursor only changes when it has to.
module Pointer
  def self.start mouse
    @mouse = mouse
    @wanted = 'arrow'
  end

  def self.over? rect, cursor = 'hand'
    return false unless @mouse&.inside_rect?(rect)

    @wanted = cursor
    true
  end

  def self.finish
    return if @wanted == @shown

    GTK.set_system_cursor @wanted
    @shown = @wanted
  end
end
