# Step 7: Implement definemethod and opt_send_without_block
#
# definemethod: Define a method in the current object's class
#   - Store the method in the receiver's class method table
#   - Push the method name (symbol) back onto the stack
#   - This is called when executing "def method_name(...); ... end"
#
# opt_send_without_block: Call a method without a block
#   - Pop argc arguments from the stack (in reverse order)
#   - Pop the receiver object
#   - Look up the method in the receiver's class
#   - Call the method via vm.invoke_method
#   - Push the result back onto the stack
#
# Example (for "def add(a, b); a + b; end; add(2, 3)"):
#   definemethod defines add in the Object class
#   opt_send_without_block looks up add, calls it with args [2, 3], gets 5
#
# CRITICAL: opt_send_without_block has special handling for :puts
#   - If method_name == :puts, capture output to $challenge_output

class YRuby::Instructions::Definemethod < YRuby::Instructions::Base
  attr_reader :method_name, :method_iseq
  def initialize(method_name, method_iseq)
    @method_name = method_name
    @method_iseq = method_iseq
  end

  def call(vm)
    # TODO: Define the method in vm.self_value.klass, then push the method name
    # Hint:
    #   vm.self_value.klass.define_method(@method_name, @method_iseq)
    #   vm.stack_push(@method_name)
    raise NotImplementedError, "Definemethod#call not implemented"
  end

  def to_s
    "#{super} :#{@method_name}"
  end
end

class YRuby::Instructions::OptSendWithoutBlock < YRuby::Instructions::Base
  attr_reader :method_name, :argc
  def initialize(method_name, argc)
    @method_name = method_name
    @argc = argc
  end

  def call(vm)
    # TODO: Pop argc arguments, pop receiver, call method, push result
    # Hint:
    #   args = []
    #   @argc.times { args.unshift(vm.stack_pop) }
    #   receiver = vm.stack_pop
    #   if @method_name == :puts
    #     args.each { |a| $challenge_output = ($challenge_output || '') + a.to_s + "\n" }
    #     vm.stack_push(nil)
    #   else
    #     method_iseq = receiver.klass.lookup_method(@method_name)
    #     result = vm.invoke_method(method_iseq: method_iseq, args: args, receiver: receiver)
    #     vm.stack_push(result)
    #   end
    raise NotImplementedError, "OptSendWithoutBlock#call not implemented"
  end

  def to_s
    "#{super} :#{@method_name}, #{@argc}"
  end
end
