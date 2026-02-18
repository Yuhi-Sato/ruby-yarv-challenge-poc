# Step 4: Implement getlocal and setlocal
#
# Local variables are stored in the stack using EP-relative addressing:
#   - EP (Environment Pointer) marks the base of the local variable area
#   - Local variable at index N is stored at: vm.stack[vm.ep - N]
#
# getlocal: READ a local variable and push it onto the stack
#   vm.stack[vm.ep - index] → push to stack
#
# setlocal: POP a value from the stack and STORE it in a local variable
#   pop from stack → vm.stack[vm.ep - index]
#   (then push the value back onto the stack, as per YARV semantics)
#
# Example (for "x = 5; x"):
#   # setlocal 0 stores 5 in vm.stack[ep - 0]
#   # getlocal 0 reads from vm.stack[ep - 0] and pushes it
#
# CRITICAL: The index is the local variable NUMBER, not an offset!
#   - First local (x) is index 0
#   - Second local (y) is index 1

class YRuby::Instructions::Getlocal < YRuby::Instructions::Base
  attr_reader :index
  def initialize(index)
    @index = index
  end

  def call(vm)
    # TODO: Read from vm.stack[vm.ep - @index] and push onto stack
    # Hint: vm.stack_push(vm.stack[vm.ep - @index])
    raise NotImplementedError, "Getlocal#call not implemented"
  end

  def to_s
    "#{super} #{@index}"
  end
end

class YRuby::Instructions::Setlocal < YRuby::Instructions::Base
  attr_reader :index
  def initialize(index)
    @index = index
  end

  def call(vm)
    # TODO: Pop from stack, store to vm.stack[vm.ep - @index], push back
    # Hint:
    #   value = vm.stack_pop
    #   vm.stack[vm.ep - @index] = value
    #   vm.stack_push(value)
    raise NotImplementedError, "Setlocal#call not implemented"
  end

  def to_s
    "#{super} #{@index}"
  end
end
