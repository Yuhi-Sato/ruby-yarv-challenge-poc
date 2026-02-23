# ============================================================
# Step 2: Addition
#
# VM:       OptPlus — pop two values, push their sum
# Compiler: compile_binary_plus — emit OptPlus for a + b
#
# After this step, `1 + 2` will evaluate to 3.
# Depends on Step 1 (Putobject / compile_integer_node).
# ============================================================

# ---- VM: OptPlus ----
#
# The stack for `1 + 2` looks like:
#   stack: [1, 2]   sp points past 2
#
# Stack is LIFO:
#   vm.topn(2) gives the left operand (a = 1)
#   vm.topn(1) gives the right operand (b = 2)
# Pop both, then push a + b.
#
# Stack before: [1, 2]
# Stack after:  [3]
#
class YRuby::Insns::OptPlus
  def self.call(vm)
    # TODO: Read both operands, pop them, push the sum
    # recv = vm.topn(2)
    # arg = vm.topn(1)
    # vm.pop
    # vm.pop
    # vm.push(recv + arg)
    raise NotImplementedError, "OptPlus.call not implemented"
  end
end

# ---- Compiler: compile_binary_plus ----
#
# When compile_call_node encounters a + operator,
# it has already compiled the left operand (node.receiver)
# and the right operand (node.arguments) onto the stack.
#
# You only need to emit the OptPlus instruction.
#
module Patch
  def compile_binary_plus(iseq, node)
    # TODO: Emit OptPlus instruction
    # iseq.emit(YRuby::Insns::OptPlus)
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
