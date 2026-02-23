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
#   0: putself
#   1: putobject 2
#   3: putobject 3
#   5: opt_send_without_block {mid: :add, argc: 2}
#   7: leave
#
# Method iseq for add(a, b):
#   0: getlocal 1   # a (reversed index)
#   2: getlocal 0   # b (reversed index)
#   4: opt_plus
#   5: leave
#
# ============================================================

# ---- VM: Definemethod ----
#
# Register method_iseq under method_name on the current object's class.
#
# vm.define_method(mid, iseq) registers the method.
#
class YRuby::Insns::Definemethod
  def self.call(vm, mid, iseq)
    # TODO: vm.define_method(mid, iseq)
    raise NotImplementedError, "Definemethod.call not implemented"
  end
end

# ---- VM: OptSendWithoutBlock ----
#
# Dispatch a method call. cd is a YRuby::CallData struct containing:
#   cd.mid   — method name (symbol)
#   cd.argc  — argument count
#
# vm.sendish(cd) handles everything:
#   - looks up the method on the receiver's class
#   - sets up a new frame with arguments
#   - execution continues in the method body
#
# Note: sendish does NOT return a value. The method's Leave instruction
# pushes the return value onto the caller's stack automatically.
#
class YRuby::Insns::OptSendWithoutBlock
  def self.call(vm, cd)
    # TODO: vm.sendish(cd)
    raise NotImplementedError, "OptSendWithoutBlock.call not implemented"
  end
end

# ---- Compiler: compile_def_node ----
#
# A DefNode represents: def method_name(params); body; end
#
# Use YRuby::Iseq.iseq_new_method(node) to compile the body into a new Iseq,
# then emit Definemethod with the name and method iseq.
# Also emit Putobject with the method name (Ruby convention: def returns name).
#
module Patch
  def compile_def_node(iseq, node)
    # TODO:
    # method_iseq = YRuby::Iseq.iseq_new_method(node)
    # iseq.emit(YRuby::Insns::Definemethod, node.name, method_iseq)
    # iseq.emit(YRuby::Insns::Putobject, node.name)
    raise NotImplementedError, "compile_def_node not implemented"
  end

  # ---- Compiler: compile_general_call ----
  #
  # A general method call: method(args)
  # (receiverless — node.receiver is nil)
  #
  # Emit Putself as the receiver (implicit self),
  # compile each argument, then emit OptSendWithoutBlock
  # with a CallData struct.
  #
  # CallData construction:
  #   cd = YRuby::CallData.new(mid: node.name, argc: args_count)
  #
  def compile_general_call(iseq, node)
    # TODO:
    # iseq.emit(YRuby::Insns::Putself)
    # argc = 0
    # if node.arguments
    #   compile_node(iseq, node.arguments)
    #   argc = node.arguments.arguments.size
    # end
    # cd = YRuby::CallData.new(mid: node.name, argc:)
    # iseq.emit(YRuby::Insns::OptSendWithoutBlock, cd)
    raise NotImplementedError, "compile_general_call not implemented"
  end
end
