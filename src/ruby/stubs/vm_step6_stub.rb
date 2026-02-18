# Step 6: Implement branchunless, jump, and leave
#
# branchunless: Conditional branch - jumps if the popped value is falsy
#   - Pop the condition
#   - If falsy (nil or false), set vm.pc = dst - 1
#   - Otherwise, continue to the next instruction
#   - CRITICAL: Set pc to dst - 1, NOT dst! The main loop does pc += 1 after each instruction
#
# jump: Unconditional branch - always jump
#   - Set vm.pc = dst - 1 (same reason as above)
#
# leave: Exit the current frame / end of execution
#   - Throw :leave to exit the execute loop
#   - This catches in the execute method and returns the final result
#
# Example (for "if 3 < 5; 10; else; 20; end"):
#   0: putobject 3
#   1: putobject 5
#   2: opt_lt                # stack = [true]
#   3: branchunless 5        # condition is true, so DON'T jump (continue to next)
#   4: putobject 10          # → execute (since condition was true)
#   5: jump 6                # jump over the else block
#   6: putobject 20          # (else block, skipped if then-branch executed)
#   7: leave                 # exit

class YRuby::Instructions::Branchunless < YRuby::Instructions::Base
  attr_reader :dst
  def initialize(dst)
    @dst = dst
  end

  def call(vm)
    # TODO: Pop a condition. If falsy, jump to @dst; otherwise, do nothing
    # Hint:
    #   condition = vm.stack_pop
    #   if !condition  # falsy means nil or false
    #     vm.pc = @dst - 1
    #   end
    # Note: In Ruby, the only falsy values are nil and false!
    raise NotImplementedError, "Branchunless#call not implemented"
  end

  def to_s
    "#{super} #{@dst}"
  end
end

class YRuby::Instructions::Jump < YRuby::Instructions::Base
  attr_reader :dst
  def initialize(dst)
    @dst = dst
  end

  def call(vm)
    # TODO: Always jump to @dst
    # Hint: vm.pc = @dst - 1
    raise NotImplementedError, "Jump#call not implemented"
  end

  def to_s
    "#{super} #{@dst}"
  end
end

class YRuby::Instructions::Leave < YRuby::Instructions::Base
  def call(vm)
    # TODO: Exit the current frame by throwing :leave
    # This will be caught by the execute loop and stop execution
    # Hint: throw :leave
    raise NotImplementedError, "Leave#call not implemented"
  end
end
