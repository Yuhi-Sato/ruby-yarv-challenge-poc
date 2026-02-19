# ============================================================
# Step 5: Comparison
#
# VM:       OptLt — pop two values, push boolean result of a < b
# Compiler: compile_binary_lt — emit OptLt for a < b
#
# After this step, `3 < 5` will evaluate to true.
# Depends on Steps 1-4.
# ============================================================

# ---- VM: OptLt ----
#
# Same LIFO pop order as OptPlus/OptMinus.
# Push a Ruby boolean: true or false.
#
# Stack before: [3, 5]
# Stack after:  [true]
#
class YRuby::Instructions::OptLt < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop b, pop a, push (a < b)
    raise NotImplementedError, "OptLt#call not implemented"
  end
end

# ---- Compiler: compile_binary_lt ----
#
# Same pattern as compile_binary_plus, but emit OptLt.
#
class YRuby::Compiler
  def compile_binary_lt(node, iseq)
    # TODO:
    # compile_node(node.receiver, iseq)
    # compile_node(node.arguments.arguments[0], iseq)
    # iseq.emit(YRuby::Instructions::OptLt.new)
    raise NotImplementedError, "compile_binary_lt not implemented"
  end
end
