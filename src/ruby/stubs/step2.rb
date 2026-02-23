class YRuby::Insns::OptPlus
  def self.call(vm)
    # TODO: Read both operands, pop them, push the sum
    raise NotImplementedError, "OptPlus.call not implemented"
  end
end

module Patch
  def compile_binary_plus(iseq, node)
    # TODO: Emit OptPlus instruction
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
