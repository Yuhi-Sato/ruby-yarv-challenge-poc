class YRuby::Insns::OptMinus
  def self.call(vm)
    # TODO: Read both operands, pop them, push a - b (order matters!)
    raise NotImplementedError, "OptMinus.call not implemented"
  end
end

module Patch
  def compile_binary_minus(iseq, node)
    # TODO: Emit OptMinus
    raise NotImplementedError, "compile_binary_minus not implemented"
  end
end
