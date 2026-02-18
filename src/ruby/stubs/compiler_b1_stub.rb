# Compiler Phase B, Step B1: Implement IntegerNode compilation
#
# IntegerNode: A literal integer in the source code (e.g., 42, 10, -5)
#
# Task: Emit a Putobject instruction with the integer value
#
# Prism AST structure:
#   Prism::IntegerNode has:
#   - node.value: the integer value (Integer)
#
# Example:
#   Source: "42"
#   AST: Prism::IntegerNode(value: 42)
#   Bytecode: [Putobject(42), Leave]
#   Execution: stack.push(42) → result = 42

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
      # TODO: Emit Putobject with node.value
      # Hint: iseq.emit(YRuby::Instructions::Putobject.new(node.value))
      raise NotImplementedError, "IntegerNode not implemented"

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
end
