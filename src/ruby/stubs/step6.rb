# ============================================================
# Step 6: Control Flow
#
# VM:       Branchunless / Jump
# Compiler: compile_conditional_node (forward-reference patching)
#
# After this step, `if 3 < 5; 10; else; 20; end` → 10.
# Depends on Steps 1-5.
#
# ---- How the execute loop works ----
#
# The VM reads the instruction class and its operands, then
# advances PC by LEN (instruction length) BEFORE executing:
#
#   insn_class = iseq.fetch(pc)
#   len = insn_class::LEN
#   operands = fetch operands...
#   pc += len             ← advanced first
#   insn_class.call(vm, *operands) ← then executed
#
# So branch instructions use vm.add_pc(offset) to adjust PC
# RELATIVE to the current position (not absolute).
#
# ---- Bytecode for: if 3 < 5; 10; else; 20; end ----
#
# The compiler uses emit_placeholder / patch_at! to backpatch
# branch offsets once the target locations are known.
#
# ============================================================

# ---- VM: Branchunless ----
#
# Pop the condition. If it is falsy (nil or false), adjust PC by dst.
# If truthy, continue to the next instruction (PC already advanced).
#
class YRuby::Insns::Branchunless
  def self.call(vm, dst)
    # TODO: Pop condition, jump if falsy
    # val = vm.topn(1)
    # vm.pop
    # vm.add_pc(dst) unless val
    raise NotImplementedError, "Branchunless.call not implemented"
  end
end

# ---- VM: Jump ----
#
# Unconditionally adjust PC by dst.
#
class YRuby::Insns::Jump
  def self.call(vm, dst)
    # TODO: vm.add_pc(dst)
    raise NotImplementedError, "Jump.call not implemented"
  end
end

# ---- Compiler: compile_conditional_node ----
#
# An IfNode has:
#   node.predicate   — the condition expression
#   node.statements  — the then-branch body
#   node.consequent  — the else-branch (ElseNode) or elsif (IfNode) or nil
#
# Because we don't know the jump offsets until after compiling the branches,
# we use forward-reference patching with emit_placeholder / patch_at!.
#
# Pattern:
#   1. compile_node(iseq, node.predicate)
#   2. branchunless_pc = iseq.size
#      iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)
#   3. compile_node(iseq, node.statements)          # then branch
#   4. then_end_pc = iseq.size
#      iseq.emit_placeholder(YRuby::Insns::Jump::LEN)
#   5. else_label = iseq.size
#      branchunless_offset = else_label - (branchunless_pc + Branchunless::LEN)
#      iseq.patch_at!(branchunless_pc, Branchunless, branchunless_offset)
#   6. if node.consequent is ElseNode:
#        compile_node(iseq, node.consequent.statements)
#      elsif node.consequent is IfNode:
#        compile_conditional_node(iseq, node.consequent)
#      end
#   7. end_label = iseq.size
#      jump_offset = end_label - (then_end_pc + Jump::LEN)
#      iseq.patch_at!(then_end_pc, Jump, jump_offset)
#
class YRuby::Compile
  def compile_conditional_node(iseq, node)
    raise NotImplementedError, "compile_conditional_node not implemented"
  end
end
