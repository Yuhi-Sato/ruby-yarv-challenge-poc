# ============================================================
# Step 1: Integer Literals
#
# VM:       Putobject — push a literal value onto the stack
# Compiler: compile_integer_node — emit Putobject for an IntegerNode
#
# After this step, `42` will evaluate to 42.
# ============================================================

# ---- VM: Putobject ----
#
# The YARV stack is an array of values.
# `vm.push(x)` places x at the top of the stack.
#
# Stack before: []
# Stack after:  [value]
#
class YRuby::Insns::Putobject
  def self.call(vm, value)
    # TODO: Push value onto the stack
    raise NotImplementedError, "Putobject.call not implemented"
  end
end

# ---- Compiler: compile_integer_node ----
#
# A Prism::IntegerNode represents a literal integer in source code.
# node.value holds the integer (e.g., 42).
#
# Emit a Putobject instruction carrying that value.
#
module Patch
  def compile_integer_node(iseq, node)
    # TODO: Emit a Putobject instruction with the integer value
    raise NotImplementedError, "compile_integer_node not implemented"
  end
end
