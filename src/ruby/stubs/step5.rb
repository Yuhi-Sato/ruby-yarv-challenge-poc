class YRuby::Insns::OptLt
  def self.call(vm)
    # TODO: Read both operands (topn), pop them, push (a < b)
    raise NotImplementedError, "OptLt.call not implemented"
  end
end

module Patch
  def compile_binary_lt(iseq, node)
    # TODO: Emit OptLt
    raise NotImplementedError, "compile_binary_lt not implemented"
  end
end
