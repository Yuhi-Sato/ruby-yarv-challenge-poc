# ============================================================
# Step 6: Control Flow
#
# VM:       Branchunless / Jump
# Compiler: compile_if_node (forward-reference patching)
#
# After this step, `if 3 < 5; 10; else; 20; end` → 10.
# Depends on Steps 1-5.
#
# Note: Leave is system-provided (every program needs it from step 1).
#
# ---- How the execute loop works ----
#
# The VM increments PC BEFORE executing each instruction:
#
#   insn = iseq[pc]
#   pc += 1          ← incremented first
#   insn.call(vm)    ← then executed
#
# So vm.set_pc(@dst) jumps to instruction @dst on the NEXT iteration.
# No off-by-one adjustment needed!
#
# ---- Bytecode for: if 3 < 5; 10; else; 20; end ----
#
#   0: Putobject(3)
#   1: Putobject(5)
#   2: OptLt                  # → true
#   3: Branchunless(5)        # condition=true: don't branch; continue to 4
#   4: Putobject(10)          # then branch
#   5: Jump(7)                # skip else branch
#   6: Putobject(20)          # else branch (skipped)
#   7: Leave
#
# ============================================================

# ---- VM: Branchunless ----
#
# Pop the condition. If it is falsy (nil or false), jump to @dst.
# If truthy, continue to the next instruction.
#
class YRuby::Instructions::Branchunless < YRuby::Instructions::Base
  def call(vm)
    # TODO: Pop condition, jump if falsy
    # cond = vm.pop
    # vm.set_pc(@dst) unless cond
    raise NotImplementedError, "Branchunless#call not implemented"
  end
end

# ---- VM: Jump ----
#
# Unconditionally jump to @dst.
#
class YRuby::Instructions::Jump < YRuby::Instructions::Base
  def call(vm)
    # TODO: vm.set_pc(@dst)
    raise NotImplementedError, "Jump#call not implemented"
  end
end

# ---- Compiler: compile_if_node ----
#
# An IfNode has:
#   node.predicate   — the condition expression
#   node.statements  — the then-branch body
#   node.subsequent  — the else-branch (ElseNode or nil)
#
# Because we don't know the jump targets until after compiling the branches,
# we use forward-reference patching with reserve_slot / set_slot.
#
# Pattern:
#   1. compile_node(node.predicate, iseq)
#   2. branchunless_idx = iseq.size
#      iseq.reserve_slot(branchunless_idx)     # placeholder
#   3. compile_node(node.statements, iseq)     # then branch
#   4. jump_idx = iseq.size
#      iseq.reserve_slot(jump_idx)             # placeholder
#   5. else_idx = iseq.size                    # NOW we know the else label
#      iseq.set_slot(branchunless_idx, Branchunless.new(else_idx))  # patch
#   6. if node.subsequent
#        compile_node(node.subsequent, iseq)   # else branch
#      else
#        iseq.emit(Putnil.new)                 # no else: push nil
#      end
#   7. end_idx = iseq.size
#      iseq.set_slot(jump_idx, Jump.new(end_idx))  # patch
#
class YRuby::Compiler
  def compile_if_node(node, iseq)
    raise NotImplementedError, "compile_if_node not implemented"
  end
end
