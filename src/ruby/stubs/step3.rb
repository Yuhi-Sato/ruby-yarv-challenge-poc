class YRuby::Insns::OptMinus
  def self.call(vm)
    # TODO: Read both operands (topn), pop them, push a - b (order matters!)
    raise NotImplementedError, "OptMinus.call not implemented"
  end
end

module Patch
  def compile_binary_minus(iseq, node)
    # Same pattern as compile_binary_plus: `10 - 3` is 10.-(3)
    #   CallNode(receiver: IntegerNode(10), name: :-, arguments: ArgumentsNode([IntegerNode(3)]))
    #
    # TODO: Compile the receiver, compile the arguments, then emit OptMinus
    raise NotImplementedError, "compile_binary_minus not implemented"
  end
end
