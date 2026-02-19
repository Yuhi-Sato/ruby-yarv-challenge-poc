# ============================================================
# Step 4: Local Variables
#
# VM:       Getlocal / Setlocal — read/write local variables
# Compiler: compile_local_var_read / compile_local_var_write
#
# After this step, `x = 5; x` will evaluate to 5.
# Depends on Steps 1-3.
#
# ---- How locals are stored ----
#
# Each frame reserves space for its local variables at the bottom
# of its stack region. The EP (Environment Pointer) points to the
# slot of local[0]:
#
#   local[0] is at stack[ep - 0] = stack[ep]
#   local[1] is at stack[ep - 1]
#   local[N] is at stack[ep - N]
#
# vm.env_read(N)       reads stack[ep - N]
# vm.env_write(N, val) writes stack[ep - N] = val
#
# The compiler assigns indices via build_local_table:
#   def add(a, b) → a gets index 0, b gets index 1
#
# ============================================================

# ---- VM: Getlocal ----
#
# Read the local variable at index @index and push it.
#
# Stack before: []
# Stack after:  [value_of_local[@index]]
#
class YRuby::Instructions::Getlocal < YRuby::Instructions::Base
  def call(vm)
    # TODO: Push the local variable at @index onto the stack
    # vm.push(vm.env_read(@index))
    raise NotImplementedError, "Getlocal#call not implemented"
  end
end

# ---- VM: Setlocal ----
#
# Pop a value from the stack and write it to local variable @index.
#
# Stack before: [value]
# Stack after:  []   (value is consumed and stored in locals)
#
class YRuby::Instructions::Setlocal < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop a value and store it in local variable @index
    # vm.env_write(@index, vm.pop)
    raise NotImplementedError, "Setlocal#call not implemented"
  end
end

# ---- Compiler: compile_local_var_read ----
#
# A Prism::LocalVariableReadNode reads a named local variable.
# node.name is the variable name (symbol, e.g., :x).
#
# Look up the index in iseq.local_table[node.name] and emit Getlocal.
#
class YRuby::Compiler
  def compile_local_var_read(node, iseq)
    # TODO:
    # index = iseq.local_table[node.name]
    # iseq.emit(YRuby::Instructions::Getlocal.new(index))
    raise NotImplementedError, "compile_local_var_read not implemented"
  end

  # ---- Compiler: compile_local_var_write ----
  #
  # A Prism::LocalVariableWriteNode assigns a value to a named local.
  # node.name is the variable name, node.value is the right-hand expression.
  #
  # Compile the value, then emit Setlocal with the variable's index.
  #
  def compile_local_var_write(node, iseq)
    # TODO:
    # compile_node(node.value, iseq)
    # index = iseq.local_table[node.name]
    # iseq.emit(YRuby::Instructions::Setlocal.new(index))
    raise NotImplementedError, "compile_local_var_write not implemented"
  end
end
