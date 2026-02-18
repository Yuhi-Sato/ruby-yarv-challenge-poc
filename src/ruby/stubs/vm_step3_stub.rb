# Step 3: Implement opt_minus
#
# opt_minus: pops two values from the stack, pushes their difference (a - b)
#
# Key insight:
#   - For "10 - 3": stack has [10, 3], pop 3 then pop 10, compute 10 - 3 = 7
#   - ORDER MATTERS! Pop b first, then a, then compute a - b
#
# Example:
#   stack.push(10)  # stack = [10]
#   stack.push(3)   # stack = [10, 3]
#   b = stack.pop   # b = 3; stack = [10]
#   a = stack.pop   # a = 10; stack = []
#   result = a - b  # result = 7
#   stack.push(7)   # stack = [7]

class YRuby::Instructions::OptMinus < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop two values, push their difference (a - b)
    # Hint:
    #   b = vm.stack_pop
    #   a = vm.stack_pop
    #   vm.stack_push(a - b)
    raise NotImplementedError, "OptMinus#call not implemented"
  end
end
