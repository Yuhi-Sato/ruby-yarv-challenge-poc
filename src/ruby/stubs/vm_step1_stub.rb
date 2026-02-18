# Step 1: Implement putobject
#
# The VM uses a STACK to store values during execution.
# putobject: pushes a literal value (like 1 or 42) onto the stack
#
# Key methods:
#   vm.stack_push(value) - push value onto stack, increment sp
#   vm.stack_pop         - decrement sp, return stack[sp]
#
# Task: Fill in the call method for Putobject

class YRuby::Instructions::Putobject < YRuby::Instructions::Base
  attr_reader :object
  def initialize(object)
    @object = object
  end

  def call(vm)
    # Push @object onto the stack
    vm.stack_push(@object)
  end

  def to_s
    "#{super} #{@object.inspect}"
  end
end
