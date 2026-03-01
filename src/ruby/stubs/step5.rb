class YRuby::Insns::OptLt
  def self.call(vm)
    # TODO: Read both operands (topn), pop them, push (a < b)
    raise NotImplementedError, "OptLt.call not implemented"
  end
end

module Patch
  def compile_binary_lt(iseq, node)
    # Same pattern as compile_binary_plus/minus: `3 < 5` is 3.<(5)
    #   CallNode(receiver: IntegerNode(3), name: :<, arguments: ArgumentsNode([IntegerNode(5)]))
    #
    # TODO: Compile the receiver, compile the arguments, then emit OptLt
    raise NotImplementedError, "compile_binary_lt not implemented"
  end
end
