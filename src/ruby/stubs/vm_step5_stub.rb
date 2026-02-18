# Step 5: Implement opt_lt
#
# opt_lt: Comparison operator "less than" (<)
#
# Behavior:
#   - Pop b, pop a
#   - Compute a < b
#   - Push the boolean result (true or false)
#
# Example (for "3 < 5"):
#   stack.push(3)     # stack = [3]
#   stack.push(5)     # stack = [3, 5]
#   b = stack.pop     # b = 5; stack = [3]
#   a = stack.pop     # a = 3; stack = []
#   result = a < b    # result = true
#   stack.push(true)  # stack = [true]

class YRuby::Instructions::OptLt < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop two values, push a < b (boolean result)
    # Hint:
    #   b = vm.stack_pop
    #   a = vm.stack_pop
    #   vm.stack_push(a < b)
    raise NotImplementedError, "OptLt#call not implemented"
  end
end
