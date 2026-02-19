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
    def initialize(name = "Object", superclass: nil)
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
      @insns = insns.dup
      @local_table = local_table.dup
      @type = type
      @param_size = param_size
    end
    def emit(instruction)
      @insns << instruction
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
        lines << if insn.nil?
          format("%04d (nil)", idx)
        else
          format("%04d %s", idx, insn.to_s)
        end
      end
      lines.join("\n")
    end
  end

  # ============================================================
  # Call metadata (matches yruby architecture)
  # ============================================================

  CallInfo = Struct.new(:mid, :argc, keyword_init: true)
  CallData = Struct.new(:ci, keyword_init: true)

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
    # System-Provided Instructions (infrastructure only)
    # These are NOT teaching points — participants don't implement these
    # ============================================================

    class Pop < Base
      def call(vm)
        vm.pop
      end
    end

    class Putself < Base
      def call(vm)
        vm.push(vm.self_value)
      end
    end

    class Putnil < Base
      def call(vm)
        vm.push(nil)
      end
    end

    class Dup < Base
      def call(vm)
        vm.push(vm.topn(1))
      end
    end

    # Leave is system-provided: every compiled program ends with Leave,
    # so it must work from step 1. The teaching points in step 6 are
    # Branchunless and Jump (the actual control-flow instructions).
    class Leave < Base
      def call(vm)
        throw :leave
      end
    end

    # ============================================================
    # Participant-Implemented Instructions
    # All raise NotImplementedError until the user provides an implementation.
    # Users override these via class reopening in their stub files.
    # ============================================================

    class Putobject < Base
      attr_reader :object
      def initialize(object)
        @object = object
      end
      def to_s
        "#{super} #{@object.inspect}"
      end
    end

    class OptPlus < Base
    end

    class OptMinus < Base
    end

    class Getlocal < Base
      attr_reader :index
      def initialize(index)
        @index = index
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
      def to_s
        "#{super} #{@index}"
      end
    end

    class OptLt < Base
    end

    class Branchunless < Base
      attr_reader :dst
      def initialize(dst)
        @dst = dst
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
      def to_s
        "#{super} :#{@method_name}"
      end
    end

    class OptSendWithoutBlock < Base
      attr_reader :cd
      def initialize(cd)
        @cd = cd
      end
      def to_s
        "#{super} :#{@cd.ci.mid}, #{@cd.ci.argc}"
      end
    end
  end
end

# ============================================================
# MinRuby — VM core (yruby-aligned architecture)
#
# Key design choices (aligned with yruby):
#   - PC is incremented BEFORE instruction execution
#     => branch instructions use vm.set_pc(@dst) directly, no -1 offset
#   - User-facing stack API: push/pop/topn
#   - User-facing locals API: env_read(index) / env_write(index, value)
#     where index 0 = first local, index 1 = second local, etc.
#   - Method calls use nested execute() via invoke_method
#   - sendish(cd) handles method dispatch (pops recv+args, calls invoke_method)
# ============================================================

class MinRuby
  STACK_SIZE = 128
  ControlFrame = Struct.new(:iseq, :pc, :sp, :ep, :type, :self_value, keyword_init: true)

  attr_reader :stack, :frames, :main

  def initialize(parser, compiler)
    @parser = parser
    @compiler = compiler
    @stack = Array.new(STACK_SIZE)
    @frames = []
    @main = YRuby::RBasic.new(YRuby::RClass.new("Object"))
  end

  def run(source)
    ast = @parser.parse(source)
    iseq = @compiler.compile(ast)
    push_frame(iseq: iseq, type: :top, sp: 0, self_value: @main)
    execute
    result = pop
    pop_frame
    result
  end

  # ============================================================
  # User-facing stack API
  # ============================================================

  # Push a value onto the stack
  def push(x)
    @stack[cfp.sp] = x
    cfp.sp += 1
  end

  # Pop a value from the stack
  def pop
    cfp.sp -= 1
    @stack[cfp.sp]
  end

  # Peek at the nth value from the top (1-indexed, topn(1) = top)
  def topn(n)
    @stack[cfp.sp - n]
  end

  # ============================================================
  # User-facing locals API (EP-relative addressing)
  # env_read(0)  reads the first local variable
  # env_read(1)  reads the second local variable
  # Internally: stack[ep - index]
  # ============================================================

  def env_read(index)
    @stack[cfp.ep - index]
  end

  def env_write(index, value)
    @stack[cfp.ep - index] = value
  end

  # ============================================================
  # User-facing control API
  # ============================================================

  # Set the program counter (for branch instructions)
  # Because PC is incremented BEFORE execution, set_pc(@dst) jumps to @dst
  def set_pc(x)
    cfp.pc = x
  end

  # The current self object
  def self_value
    cfp.self_value
  end

  # Define a method on the current self's class
  def define_method(mid, iseq)
    cfp.self_value.klass.define_method(mid, iseq)
  end

  # Dispatch a method call using CallData
  # Pops argc arguments and the receiver from the stack.
  # Special case: :puts writes to $challenge_output.
  # Returns the method's return value (caller must push it).
  def sendish(cd)
    ci = cd.ci
    argc = ci.argc
    # Collect args in order (topn(argc) is first arg, topn(1) is last)
    args = argc.times.map { |i| topn(argc - i) }
    recv = topn(argc + 1)
    (argc + 1).times { pop }

    if ci.mid == :puts
      args.each { |a| $challenge_output = ($challenge_output || '') + a.to_s + "\n" }
      return nil
    end

    method_iseq = recv.klass.lookup_method(ci.mid)
    raise "undefined method '#{ci.mid}'" unless method_iseq
    invoke_method(recv, method_iseq, args)
  end

  private

  def cfp
    @frames.last
  end

  # Push a new control frame
  # Locals are laid out from ep downward:
  #   ep - 0 = local[0] (first local / first param)
  #   ep - 1 = local[1]
  #   ep - N = local[N]
  def push_frame(iseq:, type:, sp:, self_value:, args: [])
    local_size = iseq.local_size
    ep = sp + local_size - 1
    new_sp = sp + local_size
    cf = ControlFrame.new(
      iseq: iseq, pc: 0, sp: new_sp, ep: ep,
      type: type, self_value: self_value
    )
    @frames << cf
    args.each_with_index { |a, i| env_write(i, a) }
  end

  def pop_frame
    @frames.pop
  end

  # Execute a method: push a frame, run, capture return value, pop frame
  def invoke_method(recv, method_iseq, args)
    caller_sp = cfp.sp
    push_frame(iseq: method_iseq, type: :method, sp: caller_sp, self_value: recv, args: args)
    execute
    retval = pop
    pop_frame
    retval
  end

  # Main execution loop (yruby-aligned):
  # PC is incremented BEFORE calling the instruction.
  # This means branch instructions set_pc(@dst) without any -1 adjustment.
  def execute
    catch(:leave) do
      loop do
        insn = cfp.iseq[cfp.pc]
        cfp.pc += 1
        insn.call(self)
      end
    end
  end
end
