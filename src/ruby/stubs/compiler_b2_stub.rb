# Compiler Phase B, Step B2: Implement LocalVariable node compilation
#
# LocalVariableWriteNode: Assignment to a local variable (e.g., "x = 5")
# LocalVariableReadNode: Reading a local variable (e.g., "x")
#
# Task:
#   - WriteNode: compile the RHS value, then emit Setlocal
#   - ReadNode: emit Getlocal
#
# Prism AST structure:
#   LocalVariableWriteNode:
#   - node.name: the variable name (String)
#   - node.value: the RHS expression (Node)
#
#   LocalVariableReadNode:
#   - node.name: the variable name (String)
#
# Example:
#   Source: "x = 5; x"
#   Bytecode:
#     0: Putobject(5)
#     1: Setlocal(0)      # store to stack[ep - 0]
#     2: Getlocal(0)      # load from stack[ep - 0]
#     3: Leave

class YRuby::Compiler
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

    when Prism::LocalVariableWriteNode
      # TODO: Compile the value, then emit Setlocal
      # Hint:
      #   compile_node(node.value, iseq)
      #   index = iseq.local_table[node.name]
      #   iseq.emit(YRuby::Instructions::Setlocal.new(index))
      raise NotImplementedError, "LocalVariableWriteNode not implemented"

    when Prism::LocalVariableReadNode
      # TODO: Emit Getlocal for the variable
      # Hint:
      #   index = iseq.local_table[node.name]
      #   iseq.emit(YRuby::Instructions::Getlocal.new(index))
      raise NotImplementedError, "LocalVariableReadNode not implemented"

    when Prism::CallNode
      compile_call_node(node, iseq)
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
end
