class YRuby::Insns::OptPlus
  def self.call(vm)
    # TODO: Read both operands (topn), pop them, push the sum
    raise NotImplementedError, "OptPlus.call not implemented"
  end
end

module Patch
  def compile_binary_plus(iseq, node)
    # In Ruby, `1 + 2` is parsed as a method call: 1.+(2)
    # The AST looks like:
    #   CallNode(receiver: IntegerNode(1), name: :+, arguments: ArgumentsNode([IntegerNode(2)]))
    #
    # TODO: Compile the receiver, compile the arguments, then emit OptPlus
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end
