# Try to load Prism, but have a fallback if it's not available
begin
  require 'prism'
  PRISM_AVAILABLE = true
rescue LoadError
  PRISM_AVAILABLE = false
end

class YRuby
  class Parser
    def parse(source)
      if defined?(Prism) && PRISM_AVAILABLE
        Prism.parse(source).value
      else
        # Fallback: use a simple recursive descent parser
        # For now, just support basic expressions
        parse_simple(source)
      end
    end

    private

    def parse_simple(source)
      # Very basic parser that handles simple integers, variables, and binary ops
      source = source.strip

      # Try to parse as integer
      if source =~ /^\d+$/
        return IntegerNode.new(source.to_i)
      end

      # Try to parse variable assignment: x = 5
      if source =~ /^(\w+)\s*=\s*(.+)$/
        name = $1.to_sym
        value = parse_simple($2)
        return LocalVariableWriteNode.new(name, value)
      end

      # Try to parse variable read: x
      if source =~ /^\w+$/ && source !~ /^\d+$/
        return LocalVariableReadNode.new(source.to_sym)
      end

      # Try to parse binary operations: a + b, a - b, a < b
      if source =~ /(.+?)\s*([+\-<>]=?|==|!=)\s*(.+)/
        left = parse_simple($1)
        op = $2.to_sym
        right = parse_simple($3)
        return CallNode.new(left, op, [right])
      end

      # Try to parse if/else
      if source =~ /^if\s+(.+?)\s*;\s*(.+?)\s*(?:else\s*;\s*(.+?))?\s*;\s*end$/m
        predicate = parse_simple($1)
        statements = parse_simple($2)
        subsequent = $3 ? parse_simple($3) : nil
        return IfNode.new(predicate, StatementsNode.new([statements]), subsequent)
      end

      # Try to parse method definition
      if source =~ /^def\s+(\w+)\s*(?:\((.*?)\))?\s*;\s*(.+?)\s*;\s*end$/m
        name = $1.to_sym
        params = ($2 || '').split(',').map(&:strip).map(&:to_sym)
        body = parse_simple($3)
        return DefNode.new(name, params, StatementsNode.new([body]))
      end

      # Try to parse method call
      if source =~ /^(\w+)\s*\(\s*(.+?)\s*\)$/
        method = $1.to_sym
        args = $2.split(',').map { |arg| parse_simple(arg.strip) }
        return CallNode.new(nil, method, args)
      end

      # Default: try to evaluate as integer
      begin
        return IntegerNode.new(source.to_i)
      rescue
        raise "Cannot parse: #{source}"
      end
    end
  end

  # Simple AST node classes for fallback parser
  class IntegerNode
    attr_reader :value
    def initialize(value)
      @value = value
    end
  end

  class LocalVariableReadNode
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class LocalVariableWriteNode
    attr_reader :name, :value
    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  class CallNode
    attr_reader :receiver, :name, :arguments
    def initialize(receiver, name, args)
      @receiver = receiver
      @name = name
      @arguments = ArgumentsNode.new(args)
    end
  end

  class ArgumentsNode
    attr_reader :arguments
    def initialize(args)
      @arguments = args
    end
  end

  class StatementsNode
    attr_reader :body
    def initialize(body)
      @body = body
    end
  end

  class IfNode
    attr_reader :predicate, :statements, :subsequent
    def initialize(predicate, statements, subsequent)
      @predicate = predicate
      @statements = statements
      @subsequent = subsequent
    end
  end

  class DefNode
    attr_reader :name, :parameters, :body, :locals
    def initialize(name, params, body)
      @name = name
      @body = body
      @parameters = ParametersNode.new(params)
      @locals = params
    end
  end

  class ParametersNode
    attr_reader :requireds
    def initialize(requireds)
      @requireds = requireds
    end
  end

  class Compiler
    def compile(ast)
      iseq = YRuby::Iseq.new
      compile_node(ast, iseq)
      iseq.emit(YRuby::Instructions::Leave.new)
      iseq
    end

    def compile_node(node, iseq)
      node_class = node.class.name

      if PRISM_AVAILABLE
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
      else
        # Use fallback parser node classes
        case node_class
        when 'YRuby::IntegerNode'
          iseq.emit(YRuby::Instructions::Putobject.new(node.value))
        when 'YRuby::StatementsNode'
          body = node.body
          body[0...-1].each do |stmt|
            compile_node(stmt, iseq)
            iseq.emit(YRuby::Instructions::Pop.new)
          end
          compile_node(body.last, iseq) if body.last
        when 'YRuby::LocalVariableWriteNode'
          compile_node(node.value, iseq)
          index = iseq.local_table[node.name]
          iseq.emit(YRuby::Instructions::Setlocal.new(index))
        when 'YRuby::LocalVariableReadNode'
          index = iseq.local_table[node.name]
          iseq.emit(YRuby::Instructions::Getlocal.new(index))
        when 'YRuby::CallNode'
          compile_call_node(node, iseq)
        when 'YRuby::IfNode'
          compile_if_node(node, iseq)
        when 'YRuby::DefNode'
          method_iseq = compile_method(node)
          iseq.emit(YRuby::Instructions::Definemethod.new(node.name, method_iseq))
        else
          raise "Unknown node type: #{node_class}"
        end
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
        # General method call
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

    def compile_if_node(node, iseq)
      compile_node(node.predicate, iseq)
      branchunless_idx = iseq.size
      iseq.reserve_slot(branchunless_idx)

      # Handle both Prism and fallback nodes
      if node.respond_to?(:statements)
        compile_node(node.statements, iseq)
      else
        compile_node(node.statements, iseq)
      end

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
end
