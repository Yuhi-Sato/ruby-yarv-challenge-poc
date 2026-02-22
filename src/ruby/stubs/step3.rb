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
# Same pattern as OptPlus:
#   vm.topn(2) = left operand (a)
#   vm.topn(1) = right operand (b)
# Order matters! Push a - b, NOT b - a.
#
# Stack before: [10, 3]
# Stack after:  [7]
#
class YRuby::Insns::OptMinus
  def self.call(vm)
    # TODO: Read both operands, pop them, push a - b
    # recv = vm.topn(2)
    # arg = vm.topn(1)
    # vm.pop
    # vm.pop
    # vm.push(recv - arg)
    raise NotImplementedError, "OptMinus.call not implemented"
  end
end

# ---- Compiler: compile_binary_minus ----
#
# Same pattern as compile_binary_plus, but emit OptMinus.
# The operands are already compiled by compile_call_node_dispatch.
#
class YRuby::Compile
  def compile_binary_minus(iseq, node)
    # TODO: iseq.emit(YRuby::Insns::OptMinus)
    raise NotImplementedError, "compile_binary_minus not implemented"
  end
end
