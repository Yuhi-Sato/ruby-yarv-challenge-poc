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
# Same pattern as OptPlus/OptMinus.
# Push a Ruby boolean: true or false.
#
# Stack before: [3, 5]
# Stack after:  [true]
#
class YRuby::Insns::OptLt
  def self.call(vm)
    # TODO: Read both operands, pop them, push (a < b)
    # recv = vm.topn(2)
    # arg = vm.topn(1)
    # vm.pop
    # vm.pop
    # vm.push(recv < arg)
    raise NotImplementedError, "OptLt.call not implemented"
  end
end

# ---- Compiler: compile_binary_lt ----
#
# Same pattern as compile_binary_plus, but emit OptLt.
#
class YRuby::Compile
  def compile_binary_lt(iseq, node)
    # TODO: iseq.emit(YRuby::Insns::OptLt)
    raise NotImplementedError, "compile_binary_lt not implemented"
  end
end
