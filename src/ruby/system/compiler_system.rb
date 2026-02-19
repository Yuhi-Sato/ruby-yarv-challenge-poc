# ============================================================
# YRuby Parser — wraps Prism (Ruby 4.0 built-in parser)
# ============================================================

class YRuby
  class Parser
    def parse(source)
      Prism.parse(source).value
    end
  end
end

# ============================================================
# YRuby Compiler — converts Prism AST to YRuby bytecode
#
# Architecture: method-per-node-type pattern
#   - compile_node dispatches to focused methods
#   - System handles: ProgramNode, StatementsNode, ElseNode, CallNode dispatch
#   - User implements: individual compile_* methods (all raise NotImplementedError)
#
# This allows each workshop step to override exactly one method.
# ============================================================

class YRuby
  class Compiler
    def compile(ast)
      iseq = YRuby::Iseq.new
      compile_node(ast, iseq)
      iseq.emit(YRuby::Instructions::Leave.new)
      iseq
    end

    # Main dispatch — system-provided, delegates to user-implemented methods
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
      when Prism::ElseNode
        compile_node(node.statements, iseq)
      when Prism::IntegerNode
        compile_integer_node(node, iseq)
      when Prism::LocalVariableReadNode
        compile_local_var_read(node, iseq)
      when Prism::LocalVariableWriteNode
        compile_local_var_write(node, iseq)
      when Prism::CallNode
        compile_call_node_dispatch(node, iseq)
      when Prism::IfNode
        compile_if_node(node, iseq)
      when Prism::DefNode
        compile_def_node(node, iseq)
      else
        raise "Unknown node type: #{node.class}"
      end
    end

    # ============================================================
    # User-implemented methods
    # All raise NotImplementedError until the user provides an implementation.
    # Users override these in their step stub files.
    # ============================================================

    # Step 1: Compile an integer literal → Putobject
    def compile_integer_node(node, iseq)
      raise NotImplementedError, "compile_integer_node not implemented"
    end

    # Step 4: Compile reading a local variable → Getlocal
    def compile_local_var_read(node, iseq)
      raise NotImplementedError, "compile_local_var_read not implemented"
    end

    # Step 4: Compile writing a local variable → Setlocal
    def compile_local_var_write(node, iseq)
      raise NotImplementedError, "compile_local_var_write not implemented"
    end

    # Step 2: Compile a + b → OptPlus
    def compile_binary_plus(node, iseq)
      raise NotImplementedError, "compile_binary_plus not implemented"
    end

    # Step 3: Compile a - b → OptMinus
    def compile_binary_minus(node, iseq)
      raise NotImplementedError, "compile_binary_minus not implemented"
    end

    # Step 5: Compile a < b → OptLt
    def compile_binary_lt(node, iseq)
      raise NotImplementedError, "compile_binary_lt not implemented"
    end

    # Step 6: Compile if/else with forward-reference patching
    def compile_if_node(node, iseq)
      raise NotImplementedError, "compile_if_node not implemented"
    end

    # Step 7: Compile a method definition → Definemethod
    def compile_def_node(node, iseq)
      raise NotImplementedError, "compile_def_node not implemented"
    end

    # Step 7: Compile a general method call → OptSendWithoutBlock
    def compile_general_call(node, iseq)
      raise NotImplementedError, "compile_general_call not implemented"
    end

    # ============================================================
    # System-provided dispatch helpers
    # ============================================================

    # Dispatches binary ops to user methods; routes everything else to compile_general_call
    def compile_call_node_dispatch(node, iseq)
      case node.name
      when :+  then compile_binary_plus(node, iseq)
      when :-  then compile_binary_minus(node, iseq)
      when :<  then compile_binary_lt(node, iseq)
      else          compile_general_call(node, iseq)
      end
    end

    # ============================================================
    # System-provided helpers (called from user-implemented methods)
    # ============================================================

    # Compile a method body into a new Iseq (called from compile_def_node)
    def compile_method(def_node)
      param_size = def_node.parameters&.requireds&.size || 0
      method_iseq = YRuby::Iseq.new(type: :method, param_size: param_size)
      build_local_table(method_iseq, def_node.locals)
      if def_node.body
        compile_node(def_node.body, method_iseq)
      else
        method_iseq.emit(YRuby::Instructions::Putnil.new)
      end
      method_iseq.emit(YRuby::Instructions::Leave.new)
      method_iseq
    end

    # Map local variable names to indices in the iseq local table
    # Index 0 = first local/param, index 1 = second, etc.
    def build_local_table(iseq, locals)
      locals.each_with_index do |name, index|
        iseq.local_table[name] = index
      end
    end
  end
end
