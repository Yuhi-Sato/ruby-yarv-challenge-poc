class YRuby::Insns::Putobject
  def self.call(vm, value)
    # TODO: Push value onto the stack
    raise NotImplementedError, "Putobject.call not implemented"
  end
end

module Patch
  def compile_integer_node(iseq, node)
    # TODO: Emit a Putobject instruction with node.value
    raise NotImplementedError, "compile_integer_node not implemented"
  end
end
