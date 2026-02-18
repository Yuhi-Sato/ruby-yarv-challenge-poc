# Step 2: Implement opt_plus
#
# opt_plus: pops two values from the stack, pushes their sum
#
# Key insight:
#   - The STACK is LIFO (Last In, First Out)
#   - Pop the rightmost operand first, then the leftmost
#   - For "1 + 2": stack has [1, 2], pop 2 then pop 1, compute 1 + 2 = 3
#
# Example:
#   stack.push(1)  # stack = [1]
#   stack.push(2)  # stack = [1, 2]
#   b = stack.pop  # b = 2; stack = [1]
#   a = stack.pop  # a = 1; stack = []
#   result = a + b # result = 3
#   stack.push(3)  # stack = [3]

class YRuby::Instructions::OptPlus < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop two values, push their sum
    # Hint:
    #   b = vm.stack_pop
    #   a = vm.stack_pop
    #   vm.stack_push(a + b)
    raise NotImplementedError, "OptPlus#call not implemented"
  end
end
