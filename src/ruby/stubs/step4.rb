class YRuby::Insns::Getlocal
  def self.call(vm, idx)
    # TODO: Read env_read(-idx) and push it onto the stack
    raise NotImplementedError, "Getlocal.call not implemented"
  end
end

class YRuby::Insns::Setlocal
  def self.call(vm, idx)
    # TODO: Pop the top value and store it with env_write(-idx, ...)
    raise NotImplementedError, "Setlocal.call not implemented"
  end
end

module Patch
  def compile_local_var_read(iseq, node)
    # TODO: Look up node.name in @index_lookup_table, emit Getlocal with that index
    raise NotImplementedError, "compile_local_var_read not implemented"
  end

  def compile_local_var_write(iseq, node)
    # TODO: Compile node.value, emit Dup, look up index, emit Setlocal
    raise NotImplementedError, "compile_local_var_write not implemented"
  end
end
