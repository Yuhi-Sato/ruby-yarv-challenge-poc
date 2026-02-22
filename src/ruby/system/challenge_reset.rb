# ============================================================
# Challenge Reset — stub out participant-implementable methods
#
# yruby gem provides fully working implementations. This file
# overrides the methods that workshop participants must implement,
# replacing them with NotImplementedError.
#
# Step stubs then re-override these with the participant's code.
# ============================================================

# ---- Step 1: Integer Literals ----
class YRuby::Insns::Putobject
  def self.call(vm, value)
    raise NotImplementedError, "Putobject.call not implemented"
  end
end

class YRuby::Compile
  def compile_integer_node(iseq, node)
    raise NotImplementedError, "compile_integer_node not implemented"
  end
end

# ---- Step 2: Addition ----
class YRuby::Insns::OptPlus
  def self.call(vm)
    raise NotImplementedError, "OptPlus.call not implemented"
  end
end

class YRuby::Compile
  def compile_binary_plus(iseq, node)
    raise NotImplementedError, "compile_binary_plus not implemented"
  end
end

# ---- Step 3: Subtraction ----
class YRuby::Insns::OptMinus
  def self.call(vm)
    raise NotImplementedError, "OptMinus.call not implemented"
  end
end

class YRuby::Compile
  def compile_binary_minus(iseq, node)
    raise NotImplementedError, "compile_binary_minus not implemented"
  end
end

# ---- Step 4: Local Variables ----
class YRuby::Insns::Getlocal
  def self.call(vm, idx)
    raise NotImplementedError, "Getlocal.call not implemented"
  end
end

class YRuby::Insns::Setlocal
  def self.call(vm, idx)
    raise NotImplementedError, "Setlocal.call not implemented"
  end
end

class YRuby::Compile
  def compile_local_var_read(iseq, node)
    raise NotImplementedError, "compile_local_var_read not implemented"
  end

  def compile_local_var_write(iseq, node)
    raise NotImplementedError, "compile_local_var_write not implemented"
  end
end

# ---- Step 5: Comparison ----
class YRuby::Insns::OptLt
  def self.call(vm)
    raise NotImplementedError, "OptLt.call not implemented"
  end
end

class YRuby::Compile
  def compile_binary_lt(iseq, node)
    raise NotImplementedError, "compile_binary_lt not implemented"
  end
end

# ---- Step 6: Control Flow ----
class YRuby::Insns::Branchunless
  def self.call(vm, dst)
    raise NotImplementedError, "Branchunless.call not implemented"
  end
end

class YRuby::Insns::Jump
  def self.call(vm, dst)
    raise NotImplementedError, "Jump.call not implemented"
  end
end

class YRuby::Compile
  def compile_conditional_node(iseq, node)
    raise NotImplementedError, "compile_conditional_node not implemented"
  end
end

# ---- Step 7: Methods & Fibonacci ----
class YRuby::Insns::Definemethod
  def self.call(vm, mid, iseq)
    raise NotImplementedError, "Definemethod.call not implemented"
  end
end

class YRuby::Insns::OptSendWithoutBlock
  def self.call(vm, cd)
    raise NotImplementedError, "OptSendWithoutBlock.call not implemented"
  end
end

class YRuby::Compile
  def compile_def_node(iseq, node)
    raise NotImplementedError, "compile_def_node not implemented"
  end

  def compile_general_call(iseq, node)
    raise NotImplementedError, "compile_general_call not implemented"
  end
end
