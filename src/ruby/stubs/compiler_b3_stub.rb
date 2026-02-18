# Compiler Phase B, Step B3: Implement CallNode compilation for binary operators
#
# CallNode with binary operators: +, -, <
#
# Task: Compile left operand, right operand, then emit the appropriate instruction
#
# Prism AST structure (for "a + b"):
#   Prism::CallNode has:
#   - node.name: Symbol (:+, :-, :<, etc)
#   - node.receiver: the left operand (Node)
#   - node.arguments: Arguments node with list of arguments
#   - node.arguments.arguments[0]: the first (and only) argument for binary ops
#
# Pattern:
#   Source: "1 + 2"
#   Bytecode:
#     0: Putobject(1)     # compile receiver (left operand)
#     1: Putobject(2)     # compile first argument (right operand)
#     2: OptPlus          # emit the operation
#     3: Leave
#
# For this step, implement ONLY binary arithmetic:
#   - :+ → OptPlus
#   - :- → OptMinus
#   - :< → OptLt

class YRuby::Compiler
  def compile_call_node(node, iseq)
    case node.name
    when :+
      # TODO: Compile receiver and argument, emit OptPlus
      # Hint:
      #   compile_node(node.receiver, iseq)
      #   compile_node(node.arguments.arguments[0], iseq)
      #   iseq.emit(YRuby::Instructions::OptPlus.new)
      raise NotImplementedError, "CallNode :+ not implemented"

    when :-
      # TODO: Compile receiver and argument, emit OptMinus
      raise NotImplementedError, "CallNode :- not implemented"

    when :<
      # TODO: Compile receiver and argument, emit OptLt
      raise NotImplementedError, "CallNode :< not implemented"

    when :>
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptGt.new)
    when :==
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptEq.new)
    when :!=
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptNeq.new)
    when :<=
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptLe.new)
    when :>=
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptGe.new)
    else
      # General method call (handled separately)
      if node.receiver.nil?
        iseq.emit(YRuby::Instructions::Putself.new)
      else
        compile_node(node.receiver, iseq)
      end
      args = node.arguments&.arguments || []
      args.each { |arg| compile_node(arg, iseq) }
      iseq.emit(YRuby::Instructions::OptSendWithoutBlock.new(node.name, args.size))
    end
  end

  private

  def compile_node(node, iseq)
    case node
    when Prism::ProgramNode
      build_local_table(iseq, node.locals)
      compile_node(node.statements, iseq)
    when Prism::StatementsNode
      body = node.body
      body[0...-1].each do |stmt|
        compile_node(stmt, iseq)
        iseq.emit(YRuby::Instructions::Pop.new)
      end
      compile_node(body.last, iseq) if body.last
    when Prism::IntegerNode
      iseq.emit(YRuby::Instructions::Putobject.new(node.value))
    when Prism::StringNode
      iseq.emit(YRuby::Instructions::Putstring.new(node.unescaped))
    when Prism::CallNode
      compile_call_node(node, iseq)
    when Prism::LocalVariableWriteNode
      compile_node(node.value, iseq)
      index = iseq.local_table[node.name]
      iseq.emit(YRuby::Instructions::Setlocal.new(index))
    when Prism::LocalVariableReadNode
      index = iseq.local_table[node.name]
      iseq.emit(YRuby::Instructions::Getlocal.new(index))
    when Prism::IfNode
      compile_if_node(node, iseq)
    when Prism::DefNode
      method_iseq = compile_method(node)
      iseq.emit(YRuby::Instructions::Definemethod.new(node.name, method_iseq))
    when Prism::ElseNode
      compile_node(node.statements, iseq)
    else
      raise "Unknown node type: #{node.class}"
    end
  end

  def compile_if_node(node, iseq)
    compile_node(node.predicate, iseq)
    branchunless_idx = iseq.size
    iseq.reserve_slot(branchunless_idx)
    compile_node(node.statements, iseq)
    jump_idx = iseq.size
    iseq.reserve_slot(jump_idx)
    else_idx = iseq.size
    iseq.set_slot(branchunless_idx, YRuby::Instructions::Branchunless.new(else_idx))
    if node.subsequent
      compile_node(node.subsequent, iseq)
    else
      iseq.emit(YRuby::Instructions::Putobject.new(nil))
    end
    iseq.set_slot(jump_idx, YRuby::Instructions::Jump.new(iseq.size))
  end

  def compile_method(def_node)
    method_iseq = YRuby::Iseq.new(type: :method)
    build_local_table(method_iseq, def_node.locals)
    param_size = def_node.parameters&.requireds&.size || 0
    method_iseq = YRuby::Iseq.new(
      type: :method,
      param_size: param_size,
      local_table: method_iseq.local_table
    )
    if def_node.body
      compile_node(def_node.body, method_iseq)
    else
      method_iseq.emit(YRuby::Instructions::Putobject.new(nil))
    end
    method_iseq.emit(YRuby::Instructions::Leave.new)
    method_iseq
  end

  def build_local_table(iseq, locals)
    locals.each_with_index do |name, index|
      iseq.local_table[name] = index
    end
  end
end
