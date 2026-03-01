# ============================================================
# Challenge Patch — override compiler methods for the workshop
#
# This module is prepended to YRuby::Compile so that:
# - compile_node dispatches challenge-target nodes to per-node methods
# - Non-target nodes fall through to `super` (gem's original implementation)
# - Each per-node method raises NotImplementedError until the participant
#   implements it in their step stub.
# ============================================================

module Patch
  # Override compile_node to dispatch challenge-target nodes
  # to per-node methods. Everything else falls through to the
  # gem's original compile_node via super.
  def compile_node(iseq, node)
    case node
    when Prism::IntegerNode
      compile_integer_node(iseq, node)
    when Prism::LocalVariableReadNode
      compile_local_var_read(iseq, node)
    when Prism::LocalVariableWriteNode
      compile_local_var_write(iseq, node)
    when Prism::IfNode
      compile_conditional_node(iseq, node)
    when Prism::DefNode
      compile_def_node(iseq, node)
    when Prism::CallNode
      compile_call_node(iseq, node)
    else
      super(iseq, node)
    end
  end

  # Override compile_call_node to split by operator / receiver
  def compile_call_node(iseq, node)
    if node.receiver.nil?
      compile_general_call(iseq, node)
    else
      case node.name
      when :+  then compile_binary_plus(iseq, node)
      when :-  then compile_binary_minus(iseq, node)
      when :<  then compile_binary_lt(iseq, node)
      else
        compile_node(iseq, node.receiver)
        compile_node(iseq, node.arguments) if node.arguments
        argc = node.arguments&.arguments&.size || 0
        case node.name
        when :*;  iseq.emit(YRuby::Insns::OptMult)
        when :/;  iseq.emit(YRuby::Insns::OptDiv)
        when :==; iseq.emit(YRuby::Insns::OptEq)
        when :!=; iseq.emit(YRuby::Insns::OptNeq)
        when :<=; iseq.emit(YRuby::Insns::OptLe)
        when :>;  iseq.emit(YRuby::Insns::OptGt)
        when :>=; iseq.emit(YRuby::Insns::OptGe)
        else
          cd = YRuby::CallData.new(mid: node.name, argc:)
          iseq.emit(YRuby::Insns::OptSendWithoutBlock, cd)
        end
      end
    end
  end

  # ---- Per-node methods (all raise NotImplementedError) ----
  # Participants override these in their step stubs.

  def compile_integer_node(iseq, node)
    raise NotImplementedError, "compile_integer_node not implemented"
  end

  def compile_binary_plus(iseq, node)
    raise NotImplementedError, "compile_binary_plus not implemented"
  end

  def compile_binary_minus(iseq, node)
    raise NotImplementedError, "compile_binary_minus not implemented"
  end

  def compile_local_var_read(iseq, node)
    raise NotImplementedError, "compile_local_var_read not implemented"
  end

  def compile_local_var_write(iseq, node)
    raise NotImplementedError, "compile_local_var_write not implemented"
  end

  def compile_binary_lt(iseq, node)
    raise NotImplementedError, "compile_binary_lt not implemented"
  end

  def compile_conditional_node(iseq, node)
    raise NotImplementedError, "compile_conditional_node not implemented"
  end

  def compile_def_node(iseq, node)
    raise NotImplementedError, "compile_def_node not implemented"
  end

  def compile_general_call(iseq, node)
    raise NotImplementedError, "compile_general_call not implemented"
  end
end

YRuby::Compile.prepend(Patch)
