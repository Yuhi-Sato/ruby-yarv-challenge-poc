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
# Pop order is LIFO: pop gets 2 first (b), then 1 (a).
# Result: push a + b = 3
#
# Stack before: [1, 2]
# Stack after:  [3]
#
class YRuby::Instructions::OptPlus < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop b, pop a, push a + b
    # b = vm.pop
    # a = vm.pop
    # vm.push(...)
    raise NotImplementedError, "OptPlus#call not implemented"
  end
end

# ---- Compiler: compile_binary_plus ----
#
# A binary + CallNode has:
#   node.receiver        — the left operand (e.g., 1)
#   node.arguments.arguments[0] — the right operand (e.g., 2)
#
# Compile both operands onto the stack, then emit OptPlus.
#
class YRuby::Compiler
  def compile_binary_plus(node, iseq)
    # TODO:
    # compile_node(node.receiver, iseq)
    # compile_node(node.arguments.arguments[0], iseq)
    # iseq.emit(YRuby::Instructions::OptPlus.new)
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
