# ============================================================
# YRuby Object Model - Base Ruby objects and classes
# ============================================================

class YRuby
  class RBasic
    attr_reader :klass
    def initialize(klass)
      @klass = klass
    end
  end

  class RClass
    attr_reader :name, :method_table, :superclass
    def initialize(name, superclass: nil)
      @name = name
      @method_table = {}
      @superclass = superclass
    end
    def define_method(method_name, iseq)
      @method_table[method_name] = iseq
    end
    def lookup_method(method_name)
      current = self
      while current
        iseq = current.method_table[method_name]
        return iseq if iseq
        current = current.superclass
      end
      nil
    end
  end

  # ============================================================
  # Instruction Sequence - compiled bytecode container
  # ============================================================

  class Iseq
    attr_reader :insns, :local_table, :type, :param_size
    def initialize(insns: [], local_table: {}, type: :top, param_size: 0)
      @insns = insns
      @local_table = local_table
      @type = type
      @param_size = param_size
    end
    def emit(instruction)
      @insns.push(instruction)
    end
    def size
      @insns.size
    end
    def [](index)
      @insns[index]
    end
    def reserve_slot(index)
      @insns[index] = nil
    end
    def set_slot(index, insn)
      @insns[index] = insn
    end
    def local_size
      @local_table.size
    end
    def disasm
      lines = ["== disasm =="]
      lines << "locals: #{@local_table.keys.join(', ')}" unless @local_table.empty?
      @insns.each_with_index do |insn, idx|
        if insn.nil?
          lines << format("%04d (reserved)", idx)
        else
          lines << format("%04d %s", idx, insn.to_s)
        end
      end
      lines.join("\n")
    end
  end

  # ============================================================
  # Instruction Base Class
  # ============================================================

  class Instructions
    class Base
      def call(vm)
        raise NotImplementedError, "#{self.class.name}#call not implemented"
      end
      def to_s
        self.class.name.split("::").last
          .gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      end
    end

    # ============================================================
    # System-Provided Instructions (not filled in by participants)
    # ============================================================

    class Pop < Base
      def call(vm)
        vm.stack_pop
      end
    end

    class Putself < Base
      def call(vm)
        vm.stack_push(vm.self_value)
      end
    end

    class Putstring < Base
      attr_reader :str
      def initialize(str)
        @str = str
      end
      def call(vm)
        vm.stack_push(@str)
      end
      def to_s
        "#{super} #{@str.inspect}"
      end
    end

    class OptEq < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a == b)
      end
    end

    class OptNeq < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a != b)
      end
    end

    class OptGt < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a > b)
      end
    end

    class OptLe < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a <= b)
      end
    end

    class OptGe < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a >= b)
      end
    end

    class Branchif < Base
      attr_reader :dst
      def initialize(dst)
        @dst = dst
      end
      def call(vm)
        if vm.stack_pop
          vm.pc = @dst - 1
        end
      end
      def to_s
        "#{super} #{@dst}"
      end
    end

    class Definemethod < Base
      attr_reader :method_name, :method_iseq
      def initialize(method_name, method_iseq)
        @method_name = method_name
        @method_iseq = method_iseq
      end
      def call(vm)
        vm.self_value.klass.define_method(@method_name, @method_iseq)
        vm.stack_push(@method_name)
      end
      def to_s
        "#{super} :#{@method_name}"
      end
    end

    class OptSendWithoutBlock < Base
      attr_reader :method_name, :argc
      def initialize(method_name, argc)
        @method_name = method_name
        @argc = argc
      end
      def call(vm)
        args = []
        @argc.times { args.unshift(vm.stack_pop) }
        receiver = vm.stack_pop

        result = if @method_name == :puts
          args.each { |a| $challenge_output = ($challenge_output || '') + a.to_s + "\n" }
          nil
        else
          method_iseq = receiver.klass.lookup_method(@method_name)
          raise "Unknown method: #{@method_name}" unless method_iseq
          vm.invoke_method(method_iseq: method_iseq, args: args, receiver: receiver)
        end
        vm.stack_push(result)
      end
      def to_s
        "#{super} :#{@method_name}, #{@argc}"
      end
    end

    # ============================================================
    # Instructions filled in by Participants in Phase A
    # ============================================================

    class Putobject < Base
      attr_reader :object
      def initialize(object)
        @object = object
      end
      def call(vm)
        vm.stack_push(@object)
      end
      def to_s
        "#{super} #{@object.inspect}"
      end
    end

    class OptPlus < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a + b)
      end
    end

    class OptMinus < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a - b)
      end
    end

    class Getlocal < Base
      attr_reader :index
      def initialize(index)
        @index = index
      end
      def call(vm)
        vm.stack_push(vm.stack[vm.ep - @index])
      end
      def to_s
        "#{super} #{@index}"
      end
    end

    class Setlocal < Base
      attr_reader :index
      def initialize(index)
        @index = index
      end
      def call(vm)
        vm.stack[vm.ep - @index] = vm.stack_pop
      end
      def to_s
        "#{super} #{@index}"
      end
    end

    class OptLt < Base
      def call(vm)
        b = vm.stack_pop
        a = vm.stack_pop
        vm.stack_push(a < b)
      end
    end

    class Branchunless < Base
      attr_reader :dst
      def initialize(dst)
        @dst = dst
      end
      def call(vm)
        cond = vm.stack_pop
        vm.pc = @dst - 1 if !cond
      end
      def to_s
        "#{super} #{@dst}"
      end
    end

    class Jump < Base
      attr_reader :dst
      def initialize(dst)
        @dst = dst
      end
      def call(vm)
        vm.pc = @dst - 1
      end
      def to_s
        "#{super} #{@dst}"
      end
    end

    class Leave < Base
      def call(vm)
        # Leave instruction exits the current frame and returns to the caller
        # We use throw :leave to break out of the execution loop
        throw :leave
      end
    end
  end
end

# ============================================================
# MinRuby - The actual VM
# ============================================================

class MinRuby
  STACK_SIZE = 256
  ControlFrame = Struct.new(:iseq, :pc, :sp, :ep, :type, :self_value, keyword_init: true)

  attr_accessor :stack, :cfp
  attr_reader :parser, :compiler, :main

  def initialize(parser, compiler)
    @parser = parser
    @compiler = compiler
    @stack = Array.new(STACK_SIZE)
    @cfp = STACK_SIZE
    @main = YRuby::RBasic.new(YRuby::RClass.new("Object"))
  end

  def parse(source)
    @parser.parse(source)
  end

  def compile(ast)
    @compiler.compile(ast)
  end

  def run(source)
    ast = parse(source)
    iseq = compile(ast)
    push_frame(iseq: iseq, type: :top, sp: 0, self_value: @main)
    execute
    result = stack_pop
    pop_frame
    result
  end

  def invoke_method(method_iseq:, args:, receiver: main)
    push_frame(iseq: method_iseq, type: :method, args: args, self_value: receiver)
    execute
    result = stack_pop
    pop_frame
    result
  end

  def invoke_block(block_iseq:, args:)
    push_frame(iseq: block_iseq, type: :block, args: args, self_value: current_cf.self_value)
    execute
    result = stack_pop
    pop_frame
    result
  end

  def stack_push(value)
    @stack[@cfp + 1 + sp] = value
    self.sp += 1
  end

  def stack_pop
    self.sp -= 1
    @stack[@cfp + 1 + sp]
  end

  def current_cf
    @stack[@cfp]
  end

  # Delegate methods to current_cf instead of using Forwardable (not available in ruby.wasm)
  def pc
    current_cf.pc
  end

  def pc=(value)
    current_cf.pc = value
  end

  def sp
    current_cf.sp
  end

  def sp=(value)
    current_cf.sp = value
  end

  def ep
    current_cf.ep
  end

  def ep=(value)
    current_cf.ep = value
  end

  def iseq
    current_cf.iseq
  end

  def self_value
    current_cf.self_value
  end

  private

  def push_frame(iseq:, type:, sp: nil, args: [], self_value: nil)
    frame_sp = sp || self.sp
    frame_ep = frame_sp + iseq.local_size - 1
    new_sp = frame_sp + iseq.local_size

    args.each_with_index do |arg, idx|
      @stack[frame_ep - idx] = arg
    end

    cf = ControlFrame.new(
      iseq: iseq,
      pc: 0,
      sp: new_sp,
      ep: frame_ep,
      type: type,
      self_value: self_value
    )
    @cfp -= 1
    @stack[@cfp] = cf
  end

  def pop_frame
    @cfp += 1
  end

  def execute
    catch(:leave) do
      loop do
        insn = iseq[pc]
        insn.call(self)
        self.pc += 1
      end
    end
  end
end
