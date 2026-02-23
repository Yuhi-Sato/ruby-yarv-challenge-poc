class YRuby::Insns::Definemethod
  def self.call(vm, mid, iseq)
    # TODO: Register the method with vm.define_method(mid, iseq)
    raise NotImplementedError, "Definemethod.call not implemented"
  end
end

class YRuby::Insns::OptSendWithoutBlock
  def self.call(vm, cd)
    # TODO: Dispatch the method call with vm.sendish(cd)
    raise NotImplementedError, "OptSendWithoutBlock.call not implemented"
  end
end

module Patch
  def compile_def_node(iseq, node)
    # TODO: Create method iseq, emit Definemethod, emit Putobject(name)
    raise NotImplementedError, "compile_def_node not implemented"
  end

  def compile_general_call(iseq, node)
    # TODO: Emit Putself, compile arguments, emit OptSendWithoutBlock with CallData
    raise NotImplementedError, "compile_general_call not implemented"
  end
end
