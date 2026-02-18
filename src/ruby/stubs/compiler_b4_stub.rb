# Compiler Phase B, Step B4: Implement IfNode compilation
#
# IfNode: if/else conditional statement
#
# Task: Compile with forward-reference patching using reserve_slot and set_slot
#
# The tricky part: We don't know the branch addresses until we've compiled the code!
#   - We emit a Branchunless, but don't know where to jump yet
#   - We compile the then-branch
#   - THEN we know the jump targets and can patch them
#
# Pattern:
#   compile_node(predicate)       # eval the condition
#   branchunless_idx = iseq.size
#   iseq.reserve_slot(...)        # placeholder for Branchunless
#   compile_node(then_statements) # compile then-branch
#   jump_idx = iseq.size
#   iseq.reserve_slot(...)        # placeholder for Jump
#   else_idx = iseq.size          # NOW we know where else starts!
#   iseq.set_slot(branchunless_idx, Branchunless(else_idx))  # patch Branchunless
#   compile_node(else_statements) # compile else-branch
#   iseq.set_slot(jump_idx, Jump(iseq.size))  # patch Jump to skip else
#
# Example: "if 3 < 5; 10; else; 20; end"
#   Bytecode:
#     0: Putobject(3)
#     1: Putobject(5)
#     2: OptLt                      # stack = [true]
#     3: Branchunless 5             # if false, jump to else (index 5)
#     4: Putobject(10)              # then-branch
#     5: Jump 6                     # skip else
#     6: Putobject(20)              # else-branch
#     7: Leave

class YRuby::Compiler
  def compile_if_node(node, iseq)
    # TODO: Implement if/else with forward-reference patching
    # Pattern:
    #   1. compile_node(node.predicate, iseq)
    #   2. branchunless_idx = iseq.size; iseq.reserve_slot(branchunless_idx)
    #   3. compile_node(node.statements, iseq)
    #   4. jump_idx = iseq.size; iseq.reserve_slot(jump_idx)
    #   5. else_idx = iseq.size
    #   6. iseq.set_slot(branchunless_idx, Branchunless(else_idx))
    #   7. compile_node(node.subsequent || Putobject(nil), iseq)
    #   8. iseq.set_slot(jump_idx, Jump(iseq.size))
    raise NotImplementedError, "IfNode not implemented"
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
