class YRuby::Insns::OptPlus
  def self.call(vm)
    # TODO: Read both operands (topn), pop them, push the sum
    raise NotImplementedError, "OptPlus.call not implemented"
  end
end

module Patch
  def compile_binary_plus(iseq, node)
    # TODO: Emit OptPlus
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
