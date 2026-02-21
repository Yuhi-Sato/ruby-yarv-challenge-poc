# ============================================================
# Step 7: Method Definition & Calls — FIBONACCI!
#
# VM:       Definemethod / OptSendWithoutBlock
# Compiler: compile_def_node / compile_general_call
#
# After this step, fib(10) = 55 will work!
# Depends on Steps 1-6.
#
# ---- Bytecode for: def add(a, b); a + b; end; add(2, 3) ----
#
#   0: Definemethod(:add, <method_iseq>)   # define and push :add
#   1: Pop                                 # discard :add symbol
#   2: Putself                             # receiver for add(2,3)
#   3: Putobject(2)
#   4: Putobject(3)
#   5: OptSendWithoutBlock({mid: :add, argc: 2})
#   6: Leave
#
# Method iseq for add(a, b):
#   0: Getlocal(0)   # a
#   1: Getlocal(1)   # b
#   2: OptPlus
#   3: Leave
#
# ============================================================

# ---- VM: Definemethod ----
#
# Register @method_iseq under @method_name on the current object's class.
# Then push @method_name onto the stack (Ruby convention: def returns method name).
#
# vm.define_method(mid, iseq)  registers the method
# vm.push(value)               pushes a value
#
class YRuby::Instructions::Definemethod < YRuby::Instructions::Base
  def call(vm)
    # TODO:
    # vm.define_method(@method_name, @method_iseq)
    # vm.push(@method_name)
    raise NotImplementedError, "Definemethod#call not implemented"
  end
end

# ---- VM: OptSendWithoutBlock ----
#
# Dispatch a method call. @cd is a YRuby::CallData struct containing:
#   @cd.mid   — method name (symbol)
#   @cd.argc  — argument count
#
# vm.sendish(@cd) handles everything:
#   - pops argc arguments and the receiver from the stack
#   - looks up the method on the receiver's class
#   - invokes it and returns the result
#
# After sendish returns, push the result onto the stack.
#
class YRuby::Instructions::OptSendWithoutBlock < YRuby::Instructions::Base
  def call(vm)
    # TODO:
    # result = vm.sendish(@cd)
    # vm.push(result)
    raise NotImplementedError, "OptSendWithoutBlock#call not implemented"
  end
end

# ---- Compiler: compile_def_node ----
#
# A DefNode represents: def method_name(params); body; end
#
# Use compile_method(node) to compile the body into a new Iseq,
# then emit Definemethod with the name and method iseq.
#
# compile_method is provided by the system (in compiler_system.rb).
#
class YRuby::Compiler
  def compile_def_node(node, iseq)
    # TODO:
    # method_iseq = compile_method(node)
    # iseq.emit(YRuby::Instructions::Definemethod.new(node.name, method_iseq))
    raise NotImplementedError, "compile_def_node not implemented"
  end

  # ---- Compiler: compile_general_call ----
  #
  # A general method call: receiver.method(args) or method(args)
  #
  # If node.receiver is nil, the call is on self (e.g., fib(n-1)).
  #   Emit Putself as the receiver.
  # Otherwise, compile node.receiver.
  #
  # Then compile each argument.
  # Finally, emit OptSendWithoutBlock with a CallData struct.
  #
  # CallData construction:
  #   cd = YRuby::CallData.new(mid: node.name, argc: args.size)
  #
  def compile_general_call(node, iseq)
    # TODO:
    # if node.receiver.nil?
    #   iseq.emit(YRuby::Instructions::Putself.new)
    # else
    #   compile_node(node.receiver, iseq)
    # end
    # args = node.arguments&.arguments || []
    # args.each { |arg| compile_node(arg, iseq) }
    # cd = YRuby::CallData.new(mid: node.name, argc: args.size)
    # iseq.emit(YRuby::Instructions::OptSendWithoutBlock.new(cd))
    raise NotImplementedError, "compile_general_call not implemented"
  end
end
