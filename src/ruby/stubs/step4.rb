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
# base of the local area.
#
# vm.env_read(-idx)       reads the local at index idx
# vm.env_write(-idx, val) writes the local at index idx
#
# The compiler builds an index_lookup_table that maps variable
# names to indices (reversed order from Prism's locals array).
#
# ============================================================

# ---- VM: Getlocal ----
#
# Read the local variable at index idx and push it.
#
# Stack before: []
# Stack after:  [value_of_local]
#
class YRuby::Insns::Getlocal
  def self.call(vm, idx)
    # TODO: Read env_read(-idx) and push it onto the stack
    # val = vm.env_read(-idx)
    # vm.push(val)
    raise NotImplementedError, "Getlocal.call not implemented"
  end
end

# ---- VM: Setlocal ----
#
# Pop a value from the stack and write it to local variable at idx.
#
# Stack before: [value]
# Stack after:  []   (value is consumed and stored in locals)
#
class YRuby::Insns::Setlocal
  def self.call(vm, idx)
    # TODO: Pop the top value and store it with env_write(-idx, ...)
    # val = vm.pop
    # vm.env_write(-idx, val)
    raise NotImplementedError, "Setlocal.call not implemented"
  end
end

# ---- Compiler: compile_local_var_read ----
#
# A Prism::LocalVariableReadNode reads a named local variable.
# node.name is the variable name (symbol, e.g., :x).
#
# Look up the index in index_lookup_table and emit Getlocal.
#
module Patch
  def compile_local_var_read(iseq, node)
    # TODO: Look up node.name in @index_lookup_table, emit Getlocal with that index
    # idx = @index_lookup_table[node.name]
    # iseq.emit(YRuby::Insns::Getlocal, idx)
    raise NotImplementedError, "compile_local_var_read not implemented"
  end

  # ---- Compiler: compile_local_var_write ----
  #
  # A Prism::LocalVariableWriteNode assigns a value to a named local.
  # node.name is the variable name, node.value is the right-hand expression.
  #
  # Compile the value expression first, then Dup (so the assignment
  # expression keeps its value on the stack), then Setlocal.
  #
  def compile_local_var_write(iseq, node)
    # TODO:
    # compile_node(iseq, node.value)
    # iseq.emit(YRuby::Insns::Dup)
    # idx = @index_lookup_table[node.name]
    # iseq.emit(YRuby::Insns::Setlocal, idx)
    raise NotImplementedError, "compile_local_var_write not implemented"
  end
end
