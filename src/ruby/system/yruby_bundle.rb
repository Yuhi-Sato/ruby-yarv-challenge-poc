# ============================================================
# yruby gem — bundled for ruby.wasm (browser)
#
# This file concatenates all yruby gem source files in dependency
# order, with require/require_relative calls removed.
# Generated from: https://github.com/Yuhi-Sato/yruby
# ============================================================

# --- lib/yruby/version.rb ---
class YRuby
  VERSION = "0.1.0"
end

# --- lib/yruby/core.rb ---
class YRuby
  STACK_SIZE = 128

  FRAME_TYPE_TOP = :top
  FRAME_TYPE_METHOD = :method

  ControlFrame = Struct.new(:iseq, :pc, :sp, :ep, :type, :self_value, keyword_init: true)
  ExecutionContext = Struct.new(:stack, :stack_size, :cfp, :frames, keyword_init: true)

  CallData = Struct.new(:mid, :argc, keyword_init: true)
end

# --- lib/yruby/rclass.rb ---
class YRuby
  class RClass
    def initialize
      @m_tbl = {}
    end

    def add_method_iseq(mid, iseq)
      @m_tbl[mid] = iseq
    end

    def search_method(mid)
      @m_tbl[mid]
    end
  end
end

# --- lib/yruby/robject.rb ---
class YRuby
  class RObject
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end
  end
end

# --- lib/yruby/insns/base.rb ---
class YRuby
  module Insns
    class Base
      LEN = 1

      def self.call(vm)
        raise NotImplementedError
      end
    end
  end
end

# --- lib/yruby/insns/putobject.rb ---
class YRuby
  module Insns
    class Putobject < Base
      LEN = 2

      def self.call(vm, value)
        vm.push(value)
      end
    end
  end
end

# --- lib/yruby/insns/putnil.rb ---
class YRuby
  module Insns
    class Putnil < Base
      def self.call(vm)
        vm.push(nil)
      end
    end
  end
end

# --- lib/yruby/insns/leave.rb ---
class YRuby
  module Insns
    class Leave < Base
      def self.call(vm)
        val = vm.topn(1)
        vm.pop

        type = vm.cfp.type
        vm.pop_frame

        case type
        when YRuby::FRAME_TYPE_METHOD
          vm.push(val)
        when YRuby::FRAME_TYPE_TOP
          throw :finish, val
        end
      end
    end
  end
end

# --- lib/yruby/insns/opt_plus.rb ---
class YRuby
  module Insns
    class OptPlus < Base
      def self.call(vm)
        recv = vm.topn(2)
        arg = vm.topn(1)
        vm.pop
        vm.pop
        vm.push(recv + arg)
      end
    end
  end
end

# --- lib/yruby/insns/opt_minus.rb ---
class YRuby
  module Insns
    class OptMinus < Base
      def self.call(vm)
        recv = vm.topn(2)
        arg = vm.topn(1)
        vm.pop
        vm.pop
        vm.push(recv - arg)
      end
    end
  end
end

# --- lib/yruby/insns/opt_mult.rb ---
class YRuby
  module Insns
    class OptMult < Base
      def self.call(vm)
        recv = vm.topn(2)
        arg = vm.topn(1)
        vm.pop
        vm.pop
        vm.push(recv * arg)
      end
    end
  end
end

# --- lib/yruby/insns/opt_div.rb ---
class YRuby
  module Insns
    class OptDiv < Base
      def self.call(vm)
        recv = vm.topn(2)
        arg = vm.topn(1)
        vm.pop
        vm.pop
        vm.push(recv / arg)
      end
    end
  end
end

# --- lib/yruby/insns/opt_lt.rb ---
class YRuby
  module Insns
    class OptLt < Base
      def self.call(vm)
        recv = vm.topn(2)
        arg = vm.topn(1)
        vm.pop
        vm.pop
        vm.push(recv < arg)
      end
    end
  end
end

# --- lib/yruby/insns/getlocal.rb ---
class YRuby
  module Insns
    class Getlocal < Base
      LEN = 2

      def self.call(vm, idx)
        val = vm.env_read(-idx)
        vm.push(val)
      end
    end
  end
end

# --- lib/yruby/insns/setlocal.rb ---
class YRuby
  module Insns
    class Setlocal < Base
      LEN = 2

      def self.call(vm, idx)
        val = vm.pop
        vm.env_write(-idx, val)
      end
    end
  end
end

# --- lib/yruby/insns/dup.rb ---
class YRuby
  module Insns
    class Dup < Base
      def self.call(vm)
        val = vm.topn(1)
        vm.push(val)
      end
    end
  end
end

# --- lib/yruby/insns/branchunless.rb ---
class YRuby
  module Insns
    class Branchunless < Base
      LEN = 2

      def self.call(vm, dst)
        val = vm.topn(1)
        vm.pop

        vm.add_pc(dst) unless val
      end
    end
  end
end

# --- lib/yruby/insns/jump.rb ---
class YRuby
  module Insns
    class Jump < Base
      LEN = 2

      def self.call(vm, dst)
        vm.add_pc(dst)
      end
    end
  end
end

# --- lib/yruby/insns/definemethod.rb ---
class YRuby
  module Insns
    class Definemethod < Base
      LEN = 3

      def self.call(vm, mid, iseq)
        vm.define_method(mid, iseq)
      end
    end
  end
end

# --- lib/yruby/insns/putself.rb ---
class YRuby
  module Insns
    class Putself < Base
      def self.call(vm)
        vm.push(vm.cfp.self_value)
      end
    end
  end
end

# --- lib/yruby/insns/opt_send_without_block.rb ---
class YRuby
  module Insns
    class OptSendWithoutBlock < Base
      LEN = 2

      def self.call(vm, cd)
        vm.sendish(cd)
      end
    end
  end
end

# --- lib/yruby/iseq.rb ---
class YRuby
  class Iseq
    class << self
      def iseq_new_main(ast)
        node = ast.value

        iseq = new

        Compile.new.iseq_compile_node(iseq, node)

        iseq.emit(Insns::Leave)

        iseq
      end

      def iseq_new_method(def_node)
        iseq = new

        Compile.new.iseq_compile_method(iseq, def_node)

        iseq.emit(Insns::Leave)

        params = def_node.parameters
        iseq.argc = params ? params.requireds.size : 0

        iseq
      end
    end

    attr_accessor :local_table, :local_table_size, :argc

    def initialize
      @iseq_encoded = []
      @local_table = []
      @local_table_size = 0
      @argc = 0
    end

    def emit(insn_class, *operands)
      @iseq_encoded << insn_class
      operands.each { |op| @iseq_encoded << op }
    end

    def emit_placeholder(len)
      len.times { @iseq_encoded << nil }
    end

    def patch_at!(pc, insn_class, *operands)
      @iseq_encoded[pc] = insn_class
      operands.each_with_index do |op, i|
        @iseq_encoded[pc + 1 + i] = op
      end
    end

    def fetch(pc)
      @iseq_encoded[pc]
    end

    def size
      @iseq_encoded.size
    end

    def disasm
      lines = []
      lines << "== disasm: #<ISeq:<main>@<compiled>:1> =="

      pc = 0
      while pc < @iseq_encoded.size
        insn_class = @iseq_encoded[pc]
        len = insn_class::LEN
        operands = @iseq_encoded[pc + 1, len - 1]
        name = insn_class.name.split('::').last
          .gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        if operands.empty?
          lines << format("%04d %s", pc, name)
        else
          lines << format("%04d %s %s", pc, name, operands.map(&:inspect).join(', '))
        end
        pc += len
      end

      lines.join("\n")
    end
  end
end

# --- lib/yruby/compile.rb ---
class YRuby
  class Compile
    attr_reader :index_lookup_table

    def iseq_compile_node(iseq, node)
      @index_lookup_table = {}
      insert_local_index(@index_lookup_table, node.locals)
      iseq_set_local_table(iseq, node.locals)
      compile_node(iseq, node)
    end

    def iseq_compile_method(iseq, def_node)
      @index_lookup_table = {}
      insert_local_index(@index_lookup_table, def_node.locals)
      iseq_set_local_table(iseq, def_node.locals)

      if def_node.body
        compile_node(iseq, def_node.body)
      else
        iseq.emit(YRuby::Insns::Putnil)
      end
    end

    # ============================================================
    # Main dispatch — delegates to individual compile methods
    # ============================================================

    def compile_node(iseq, node)
      case node
      when Prism::ProgramNode
        compile_node(iseq, node.statements)
      when Prism::StatementsNode
        node.body.each { |stmt| compile_node(iseq, stmt) }
      when Prism::IntegerNode
        compile_integer_node(iseq, node)
      when Prism::NilNode
        iseq.emit(YRuby::Insns::Putnil)
      when Prism::TrueNode
        iseq.emit(YRuby::Insns::Putobject, true)
      when Prism::FalseNode
        iseq.emit(YRuby::Insns::Putobject, false)
      when Prism::CallNode
        compile_call_node_dispatch(iseq, node)
      when Prism::ArgumentsNode
        node.arguments.each { |arg| compile_node(iseq, arg) }
      when Prism::LocalVariableWriteNode
        compile_local_var_write(iseq, node)
      when Prism::LocalVariableReadNode
        compile_local_var_read(iseq, node)
      when Prism::IfNode
        compile_conditional_node(iseq, node)
      when Prism::DefNode
        compile_def_node(iseq, node)
      else
        raise "Unknown node: #{node.class}"
      end
    end

    # ============================================================
    # Individual compile methods (overridable by monkey-patching)
    # ============================================================

    def compile_integer_node(iseq, node)
      iseq.emit(YRuby::Insns::Putobject, node.value)
    end

    def compile_local_var_write(iseq, node)
      compile_node(iseq, node.value)
      iseq.emit(YRuby::Insns::Dup)
      idx = @index_lookup_table[node.name]
      iseq.emit(YRuby::Insns::Setlocal, idx)
    end

    def compile_local_var_read(iseq, node)
      idx = @index_lookup_table[node.name]
      iseq.emit(YRuby::Insns::Getlocal, idx)
    end

    # Dispatch binary ops to individual methods; receiverless calls to compile_general_call
    def compile_call_node_dispatch(iseq, node)
      if node.receiver.nil?
        compile_general_call(iseq, node)
      else
        compile_node(iseq, node.receiver)
        compile_node(iseq, node.arguments)

        case node.name
        when :+  then compile_binary_plus(iseq, node)
        when :-  then compile_binary_minus(iseq, node)
        when :*  then compile_binary_mult(iseq, node)
        when :/  then compile_binary_div(iseq, node)
        when :<  then compile_binary_lt(iseq, node)
        else
          raise "Unknown operator: #{node.name}"
        end
      end
    end

    def compile_binary_plus(iseq, node)
      iseq.emit(YRuby::Insns::OptPlus)
    end

    def compile_binary_minus(iseq, node)
      iseq.emit(YRuby::Insns::OptMinus)
    end

    def compile_binary_mult(iseq, node)
      iseq.emit(YRuby::Insns::OptMult)
    end

    def compile_binary_div(iseq, node)
      iseq.emit(YRuby::Insns::OptDiv)
    end

    def compile_binary_lt(iseq, node)
      iseq.emit(YRuby::Insns::OptLt)
    end

    def compile_general_call(iseq, node)
      iseq.emit(YRuby::Insns::Putself)
      argc = 0
      if node.arguments
        compile_node(iseq, node.arguments)
        argc = node.arguments.arguments.size
      end
      cd = CallData.new(mid: node.name, argc:)
      iseq.emit(YRuby::Insns::OptSendWithoutBlock, cd)
    end

    def compile_def_node(iseq, node)
      method_iseq = YRuby::Iseq.iseq_new_method(node)
      iseq.emit(YRuby::Insns::Definemethod, node.name, method_iseq)
      iseq.emit(YRuby::Insns::Putobject, node.name)
    end

    def compile_conditional_node(iseq, node)
      compile_node(iseq, node.predicate)
      branchunless_pc = iseq.size
      iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)

      # then statements
      compile_node(iseq, node.statements)

      then_end_pc = iseq.size
      iseq.emit_placeholder(YRuby::Insns::Jump::LEN)

      else_label = iseq.size
      branchunless_offset = else_label - (branchunless_pc + YRuby::Insns::Branchunless::LEN)
      iseq.patch_at!(branchunless_pc, YRuby::Insns::Branchunless, branchunless_offset)

      # elsif / else statements
      case node.consequent
      when Prism::IfNode
        compile_conditional_node(iseq, node.consequent)
      when Prism::ElseNode
        compile_node(iseq, node.consequent.statements)
      end

      end_label = iseq.size
      jump_offset = end_label - (then_end_pc + YRuby::Insns::Jump::LEN)
      iseq.patch_at!(then_end_pc, YRuby::Insns::Jump, jump_offset)
    end

    private

    def insert_local_index(index_lookup_table, locals)
      locals.reverse_each.with_index do |local, index|
        index_lookup_table[local] = index
      end
    end

    def iseq_set_local_table(iseq, locals)
      iseq.local_table_size = locals.size
      iseq.local_table = locals.dup
    end
  end
end

# --- lib/yruby/parser.rb ---
class YRuby
  class Parser
    def parse(source)
      result = Prism.parse(source)

      result
    end
  end
end

# --- lib/yruby/insnhelper.rb ---
class YRuby
  module InsnHelper
    module Macros
      # Value Stack
      def push(x)
        set_sv(x)
        inc_sp(1)
      end

      def topn(x)
        stack[cfp.sp - x]
      end

      def pop
        cfp.sp -= 1
        val = stack[cfp.sp]
        stack[cfp.sp] = nil
        val
      end

      # PC
      def add_pc(x)
        cfp.pc += x
      end

      # environment pointer
      def get_ep
        cfp.ep
      end

      # SP
      def set_sv(x)
        stack[cfp.sp] = x
      end

      def inc_sp(x)
        cfp.sp += x
      end
    end

    # Control Frame
    def push_frame(iseq:, type: FRAME_TYPE_TOP, self_value: nil, sp:)
      sp = sp + iseq.local_table_size
      ep = sp - 1

      cf = ControlFrame.new(iseq:, pc: 0, sp:, ep:, type:, self_value:)
      frames.push(cf)
      self.cfp = cf
    end

    def pop_frame
      frames.pop
      self.cfp = frames.last
    end

    # Environment Pointer
    def env_read(index)
      stack[get_ep + index]
    end

    def env_write(index, value)
      stack[get_ep + index] = value
    end

    def define_method(mid, iseq)
      klass = cfp.self_value.klass

      klass.add_method_iseq(mid, iseq)
    end

    def call_iseq_setup(recv, argc, method_iseq)
      argv_index = cfp.sp - argc
      recv_index = argv_index - 1

      cfp.sp = recv_index

      push_frame(
        iseq: method_iseq,
        type: FRAME_TYPE_METHOD,
        self_value: recv,
        sp: argv_index
      )

      local_only_size = method_iseq.local_table_size - method_iseq.argc
      local_only_size.times do |i|
        env_write(-i, nil)
      end
    end

    def sendish(cd)
      argc = cd.argc
      recv = topn(argc + 1)

      klass = recv.klass
      method_iseq = klass.search_method(cd.mid)

      raise "undefined method #{cd.mid}" if method_iseq.nil?

      call_iseq_setup(recv, argc, method_iseq)
    end
  end
end

# --- lib/yruby.rb ---
class YRuby
  include InsnHelper
  include InsnHelper::Macros

  attr_reader :ec

  def initialize(parser = Parser.new)
    @parser = parser
  end

  def exec(source)
    init

    ast = @parser.parse(source)

    iseq = Iseq.iseq_new_main(ast)

    exec_core(iseq)
  end

  private

  def init
    stack = Array.new(STACK_SIZE)
    frames = []
    @ec = ExecutionContext.new(stack:, stack_size: STACK_SIZE, frames:)
    @top_self = RObject.new(RClass.new)
  end

  def exec_core(iseq)
    push_frame(iseq:, type: FRAME_TYPE_TOP, self_value: @top_self, sp: 0)

    catch(:finish) do
      loop do
        insn_class = cfp.iseq.fetch(cfp.pc)
        len = insn_class::LEN
        operands = (1...len).map { |i| cfp.iseq.fetch(cfp.pc + i) }
        add_pc(len)
        insn_class.call(self, *operands)
      end
    end
  end
end

# --- InsnHelper delegators (replaces Forwardable) ---
class YRuby
  def cfp
    @ec.cfp
  end

  def cfp=(val)
    @ec.cfp = val
  end

  def stack
    @ec.stack
  end

  def frames
    @ec.frames
  end
end
