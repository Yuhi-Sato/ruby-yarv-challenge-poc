# Compiler Phase B, Step B5: Implement DefNode and general CallNode
#
# DefNode: Method definition ("def method_name(...); ... end")
#   - Compile to a separate Iseq for the method body
#   - Emit Definemethod to register the method in the class
#
# General CallNode (recursive method calls):
#   - For calls like "fib(n-1)" where the receiver is nil (implicit self)
#   - Compile: receiver (Putself), args, then OptSendWithoutBlock
#
# Example: "def fib(n); if n < 2; n; else; fib(n-1) + fib(n-2); end; end; fib(10)"
#   - DefNode emits Definemethod for fib
#   - The recursive "fib(n-1)" is a CallNode with nil receiver
#   - It compiles to: Putself, Getlocal(0), Putobject(1), OptMinus, OptSendWithoutBlock(:fib, 1)
#
# CRITICAL: The system already provides compile_method, compile_if_node, and compile_call_node
# YOUR TASK: Implement DefNode handling and the general method call path

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
      # TODO: Implement DefNode compilation
      # Hint:
      #   method_iseq = compile_method(node)
      #   iseq.emit(YRuby::Instructions::Definemethod.new(node.name, method_iseq))
      raise NotImplementedError, "DefNode not implemented"

    when Prism::ElseNode
      compile_node(node.statements, iseq)
    else
      raise "Unknown node type: #{node.class}"
    end
  end

  private

  def compile_call_node(node, iseq)
    case node.name
    when :+
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptPlus.new)
    when :-
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptMinus.new)
    when :<
      compile_node(node.receiver, iseq)
      compile_node(node.arguments.arguments[0], iseq)
      iseq.emit(YRuby::Instructions::OptLt.new)
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
      # General method call (including recursive calls like "fib(n-1)")
      # TODO: Implement general method call compilation
      # Hint:
      #   if node.receiver.nil?
      #     iseq.emit(YRuby::Instructions::Putself.new)
      #   else
      #     compile_node(node.receiver, iseq)
      #   end
      #   args = node.arguments&.arguments || []
      #   args.each { |arg| compile_node(arg, iseq) }
      #   iseq.emit(YRuby::Instructions::OptSendWithoutBlock.new(node.name, args.size))
      raise NotImplementedError, "General method call (#{node.name}) not implemented"
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
