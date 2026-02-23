class YRuby::Insns::Branchunless
  def self.call(vm, dst)
    # TODO: Pop condition; if falsy (nil or false), call vm.add_pc(dst)
    raise NotImplementedError, "Branchunless.call not implemented"
  end
end

class YRuby::Insns::Jump
  def self.call(vm, dst)
    # TODO: Unconditionally call vm.add_pc(dst)
    raise NotImplementedError, "Jump.call not implemented"
  end
end

module Patch
  def compile_conditional_node(iseq, node)
    # TODO: See the TutorialPane for the forward-reference patching algorithm
    raise NotImplementedError, "compile_conditional_node not implemented"
  end
end
