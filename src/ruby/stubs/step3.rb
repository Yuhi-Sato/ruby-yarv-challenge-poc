# ============================================================
# Step 3: Subtraction
#
# VM:       OptMinus — pop two values, push their difference
# Compiler: compile_binary_minus — emit OptMinus for a - b
#
# After this step, `10 - 3` will evaluate to 7.
# Depends on Steps 1-2.
# ============================================================

# ---- VM: OptMinus ----
#
# Same LIFO order as OptPlus — pop b first, then a.
# Order matters! a - b, NOT b - a.
#
# Stack before: [10, 3]
# Stack after:  [7]
#
class YRuby::Instructions::OptMinus < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop b, pop a, push a - b
    raise NotImplementedError, "OptMinus#call not implemented"
  end
end

# ---- Compiler: compile_binary_minus ----
#
# Same pattern as compile_binary_plus, but emit OptMinus.
#
class YRuby::Compiler
  def compile_binary_minus(node, iseq)
    # TODO:
    # compile_node(node.receiver, iseq)
    # compile_node(node.arguments.arguments[0], iseq)
    # iseq.emit(YRuby::Instructions::OptMinus.new)
    raise NotImplementedError, "compile_binary_minus not implemented"
  end
end
