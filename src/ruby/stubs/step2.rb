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
# Stack is LIFO: the first pop gives the right operand (b),
# the second pop gives the left operand (a).
# Push a + b.
#
# Stack before: [1, 2]
# Stack after:  [3]
#
class YRuby::Instructions::OptPlus < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop the right operand (b), then the left (a), push a + b
    raise NotImplementedError, "OptPlus#call not implemented"
  end
end

# ---- Compiler: compile_binary_plus ----
#
# A binary + CallNode has:
#   node.receiver        — the left operand (e.g., 1)
#   node.arguments.arguments[0] — the right operand (e.g., 2)
#
# Compile the left operand, compile the right operand,
# then emit OptPlus.
#
class YRuby::Compiler
  def compile_binary_plus(node, iseq)
    # TODO: Compile left, compile right, emit OptPlus
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
