# Ctrl+V (Cmd+V on macOS) for the text inputs: the clipboard's first line, trimmed, read through SDL the same way
# DragonRuby's own console pastes ($gtk.ffi_misc.getclipboard; not in the docs, but the console relies on it).
module Clipboard
  # The pasted text this tick, or nil. ctrl_v / meta_v: V pressed this tick while Ctrl / Cmd is down *or held*
  # (Ctrl is usually held from an earlier tick, so key_down.control alone misses it).
  def self.pasted keyboard
    return nil unless keyboard.ctrl_v || keyboard.meta_v

    first_line GTK.ffi_misc.getclipboard.to_s
  end

  def self.first_line text
    text.split("\n").first.to_s.strip
  end

  # This tick's typed characters plus anything pasted, for Field#update and CommandBar#update.
  def self.typed inputs
    pasted = pasted(inputs.keyboard)
    pasted && !pasted.empty? ? inputs.text + [pasted] : inputs.text
  end
end
