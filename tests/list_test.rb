def test_list_stacks_buttons_down_from_the_top args, assert
  first, second = List.buttons(%w[a b], 60, 580)
  assert.equal! [first.x, first.y, first.value], [60, 580, 'a']
  assert.equal! [second.x, second.y, second.text], [60, 580 - List::STEP, 'b']
end

def test_list_starts_a_new_column_after_rows args, assert
  buttons = List.buttons((1..(List::ROWS + 1)).map(&:to_s), 60, 580)
  assert.equal! [buttons.last.x, buttons.last.y], [60 + List::W + 20, 580]
end
