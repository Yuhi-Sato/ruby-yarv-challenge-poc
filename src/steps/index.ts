import { createElement as h } from 'react'
import type { StepConfig } from '../types'

// Import combined stubs as raw strings
import step1Stub from '../ruby/stubs/step1.rb?raw'
import step2Stub from '../ruby/stubs/step2.rb?raw'
import step3Stub from '../ruby/stubs/step3.rb?raw'
import step4Stub from '../ruby/stubs/step4.rb?raw'
import step5Stub from '../ruby/stubs/step5.rb?raw'
import step6Stub from '../ruby/stubs/step6.rb?raw'
import step7Stub from '../ruby/stubs/step7.rb?raw'

export const STEPS: StepConfig[] = [
  {
    id: 1,
    title: 'Step 1: Integer Literals',
    description: h('div', null,
      h('h2', null, 'Step 1: Push Literals onto the Stack'),
      h('p', null,
        'YARV is a ', h('strong', null, 'stack machine'), '. Every value flows through a stack of fixed size.'
      ),
      h('h3', null, 'VM: Putobject'),
      h('ul', null,
        h('li', null, h('code', null, 'putobject'), ' pushes a literal value onto the stack'),
        h('li', null, 'Use ', h('code', null, 'vm.push(value)'), ' to push'),
      ),
      h('h3', null, 'Compiler: compile_integer_node'),
      h('ul', null,
        h('li', null, h('code', null, 'Prism::IntegerNode'), ' represents a literal integer (e.g. ', h('code', null, '42'), ')'),
        h('li', null, h('code', null, 'node.value'), ' holds the integer — emit ', h('code', null, 'iseq.emit(Putobject, node.value)')),
      ),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.push(x)                       # Push x onto the stack\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.emit(InsnClass, *operands)  # Append instruction to iseq'
      )),
    ),
    instructions: 'putobject · compile_integer_node',
    stub: step1Stub,
    testCases: [
      { description: '42 → 42', source: '42', expected: 42 },
      { description: '100 → 100', source: '100', expected: 100 },
      { description: '0 → 0', source: '0', expected: 0 },
    ],
    bytecodePreview: `0000 putobject 42\n0002 leave`,
  },

  {
    id: 2,
    title: 'Step 2: Addition',
    description: h('div', null,
      h('h2', null, 'Step 2: Arithmetic — Addition'),
      h('h3', null, 'VM: OptPlus'),
      h('ul', null,
        h('li', null, h('code', null, 'opt_plus'), ' pops two values and pushes their sum'),
        h('li', null,
          'Stack is LIFO: ', h('code', null, 'vm.topn(2)'), ' = left operand (a), ',
          h('code', null, 'vm.topn(1)'), ' = right operand (b)'
        ),
        h('li', null, 'Pop both, then push ', h('code', null, 'a + b')),
      ),
      h('h3', null, 'Compiler: compile_binary_plus'),
      h('ul', null,
        h('li', null, 'The operands are already compiled by ', h('code', null, 'compile_call_node_dispatch')),
        h('li', null, 'You only need to emit ', h('code', null, 'iseq.emit(YRuby::Insns::OptPlus)')),
      ),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.topn(n)                       # Peek nth from top (1 = top, 2 = second)\n' +
        'vm.pop                           # Pop and return top value\n' +
        'vm.push(x)                       # Push x onto the stack\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.emit(InsnClass, *operands)  # Append instruction to iseq'
      )),
    ),
    instructions: 'opt_plus · compile_binary_plus',
    stub: step2Stub,
    testCases: [
      { description: '1 + 2 = 3', source: '1 + 2', expected: 3 },
      { description: '10 + 5 = 15', source: '10 + 5', expected: 15 },
      { description: '0 + 0 = 0', source: '0 + 0', expected: 0 },
    ],
    bytecodePreview: `0000 putobject 1\n0002 putobject 2\n0004 opt_plus\n0005 leave`,
  },

  {
    id: 3,
    title: 'Step 3: Subtraction',
    description: h('div', null,
      h('h2', null, 'Step 3: Arithmetic — Subtraction'),
      h('h3', null, 'VM: OptMinus'),
      h('ul', null,
        h('li', null, h('code', null, 'opt_minus'), ': peek a = ', h('code', null, 'topn(2)'), ', b = ', h('code', null, 'topn(1)'), ', push ', h('code', null, 'a − b')),
        h('li', null, h('strong', null, 'Order matters!'), ' a − b, not b − a'),
      ),
      h('h3', null, 'Compiler: compile_binary_minus'),
      h('ul', null,
        h('li', null, 'Same pattern as ', h('code', null, 'compile_binary_plus'), ', but emit ', h('code', null, 'OptMinus')),
      ),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.topn(n)                       # Peek nth from top (1 = top, 2 = second)\n' +
        'vm.pop                           # Pop and return top value\n' +
        'vm.push(x)                       # Push x onto the stack\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.emit(InsnClass, *operands)  # Append instruction to iseq'
      )),
    ),
    instructions: 'opt_minus · compile_binary_minus',
    stub: step3Stub,
    testCases: [
      { description: '10 - 3 = 7', source: '10 - 3', expected: 7 },
      { description: '5 - 5 = 0', source: '5 - 5', expected: 0 },
      { description: '100 - 50 = 50', source: '100 - 50', expected: 50 },
    ],
    bytecodePreview: `0000 putobject 10\n0002 putobject 3\n0004 opt_minus\n0005 leave`,
  },

  {
    id: 4,
    title: 'Step 4: Local Variables',
    description: h('div', null,
      h('h2', null, 'Step 4: Local Variable Storage'),
      h('h3', null, 'EP-Relative Addressing'),
      h('p', null,
        'Locals live in the stack, addressed via the ',
        h('strong', null, 'EP (Environment Pointer)'),
        '. Each frame reserves slots at a negative offset from EP:'
      ),
      h('ul', null,
        h('li', null, h('code', null, 'env_read(-idx)'), ' → read local at index idx'),
        h('li', null, h('code', null, 'env_write(-idx, val)'), ' → write local at index idx'),
        h('li', null, 'Internally: ', h('code', null, 'stack[ep + (-idx)]')),
      ),
      h('h3', null, 'VM: Getlocal / Setlocal'),
      h('ul', null,
        h('li', null, h('strong', null, 'Getlocal(idx)'), ': read ', h('code', null, 'env_read(-idx)'), ', push it'),
        h('li', null, h('strong', null, 'Setlocal(idx)'), ': pop a value, write it with ', h('code', null, 'env_write(-idx, val)')),
      ),
      h('h3', null, 'Compiler: compile_local_var_read / write'),
      h('ul', null,
        h('li', null, 'Look up index: ', h('code', null, '@index_lookup_table[node.name]')),
        h('li', null, 'For write: compile value, emit ', h('code', null, 'Dup'), ', then ', h('code', null, 'Setlocal')),
        h('li', null, 'The ', h('code', null, 'Dup'), ' keeps the assignment expression\'s value on the stack (Ruby convention: ', h('code', null, 'x = 5'), ' evaluates to ', h('code', null, '5'), ')'),
      ),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.push(x)                       # Push x onto the stack\n' +
        'vm.pop                           # Pop and return top value\n' +
        'vm.env_read(-idx)                # Read local at index idx\n' +
        'vm.env_write(-idx, val)          # Write local at index idx\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.emit(InsnClass, *operands)  # Append instruction to iseq\n' +
        '\n' +
        '# Compiler internal\n' +
        '@index_lookup_table[node.name]   # Variable name (Symbol) → slot index (Integer)'
      )),
    ),
    instructions: 'getlocal · setlocal · compile_local_var_read · compile_local_var_write',
    stub: step4Stub,
    testCases: [
      { description: 'x = 5; x → 5', source: 'x = 5; x', expected: 5 },
      { description: 'a = 10; b = 20; a + b → 30', source: 'a = 10; b = 20; a + b', expected: 30 },
    ],
    bytecodePreview: `0000 putobject 5\n0002 dup\n0003 setlocal 0\n0005 getlocal 0\n0007 leave`,
  },

  {
    id: 5,
    title: 'Step 5: Comparison',
    description: h('div', null,
      h('h2', null, 'Step 5: Comparison — Less Than'),
      h('h3', null, 'VM: OptLt'),
      h('ul', null,
        h('li', null, h('code', null, 'opt_lt'), ': peek a = ', h('code', null, 'topn(2)'), ', b = ', h('code', null, 'topn(1)'), ', push ', h('code', null, 'a < b')),
        h('li', null, 'Same pop-two-push-one pattern as ', h('code', null, 'opt_plus'), ' / ', h('code', null, 'opt_minus')),
        h('li', null, 'Result is a Ruby boolean: ', h('code', null, 'true'), ' or ', h('code', null, 'false')),
      ),
      h('h3', null, 'Compiler: compile_binary_lt'),
      h('ul', null,
        h('li', null, 'Same pattern as compile_binary_plus, but emit ', h('code', null, 'OptLt')),
      ),
      h('p', null,
        'The boolean result will be consumed by the branch instructions in Step 6.'
      ),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.topn(n)                       # Peek nth from top (1 = top, 2 = second)\n' +
        'vm.pop                           # Pop and return top value\n' +
        'vm.push(x)                       # Push x onto the stack\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.emit(InsnClass, *operands)  # Append instruction to iseq'
      )),
    ),
    instructions: 'opt_lt · compile_binary_lt',
    stub: step5Stub,
    testCases: [
      { description: '3 < 5 → true', source: '3 < 5', expected: true },
      { description: '10 < 5 → false', source: '10 < 5', expected: false },
      { description: '5 < 5 → false', source: '5 < 5', expected: false },
    ],
    bytecodePreview: `0000 putobject 3\n0002 putobject 5\n0004 opt_lt\n0005 leave`,
  },

  {
    id: 6,
    title: 'Step 6: Control Flow',
    description: h('div', null,
      h('h2', null, 'Step 6: Conditional Branching'),
      h('h3', null, 'Key Insight: PC and Relative Offsets'),
      h('p', null,
        'The VM advances PC by instruction length ', h('strong', null, 'before'), ' executing:'
      ),
      h('pre', null, h('code', null,
        'insn = iseq.fetch(pc)\n' +
        'pc += insn::LEN    # ← advanced first\n' +
        'insn.call(vm, ...) # ← then executed'
      )),
      h('p', null,
        'Branch instructions use ', h('strong', null, 'relative offsets'), ': ',
        h('code', null, 'vm.add_pc(dst)'), ' adjusts PC by dst from the current (already-advanced) position.'
      ),
      h('h3', null, 'VM: Branchunless'),
      h('ul', null,
        h('li', null, 'Pop condition; if ', h('strong', null, 'falsy'), ' (nil or false), ', h('code', null, 'vm.add_pc(dst)'))
      ),
      h('h3', null, 'VM: Jump'),
      h('ul', null,
        h('li', null, 'Unconditionally ', h('code', null, 'vm.add_pc(dst)'))
      ),
      h('h3', null, 'Compiler: compile_conditional_node'),
      h('p', null,
        'Because jump targets aren\'t known until after compiling branches, use ',
        h('strong', null, 'forward-reference patching'), ':'
      ),
      h('pre', null, h('code', null,
        '# node fields: node.predicate, node.statements, node.consequent\n' +
        '\n' +
        '# 1. Compile the condition\n' +
        'compile_node(iseq, node.predicate)\n' +
        '\n' +
        '# 2. Reserve a slot for branchunless (target unknown yet)\n' +
        'branchunless_pc = iseq.size\n' +
        'iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)\n' +
        '\n' +
        '# 3. Compile then-branch\n' +
        'compile_node(iseq, node.statements)\n' +
        '\n' +
        '# 4. Reserve a slot for the jump over else\n' +
        'then_end_pc = iseq.size\n' +
        'iseq.emit_placeholder(YRuby::Insns::Jump::LEN)\n' +
        '\n' +
        '# 5. Patch branchunless to skip to else\n' +
        'else_label = iseq.size\n' +
        'iseq.patch_at!(branchunless_pc, YRuby::Insns::Branchunless,\n' +
        '  else_label - (branchunless_pc + YRuby::Insns::Branchunless::LEN))\n' +
        '\n' +
        '# 6. Compile else-branch (node.consequent may be ElseNode or IfNode)\n' +
        '\n' +
        '# 7. Patch jump to skip to end\n' +
        'end_label = iseq.size\n' +
        'iseq.patch_at!(then_end_pc, YRuby::Insns::Jump,\n' +
        '  end_label - (then_end_pc + YRuby::Insns::Jump::LEN))'
      )),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.topn(1)                              # Peek top value (do not pop)\n' +
        'vm.pop                                  # Pop and return top value\n' +
        'vm.add_pc(n)                            # Adjust PC by relative offset n\n' +
        '\n' +
        '# Iseq\n' +
        'iseq.size                               # Current instruction count\n' +
        'iseq.emit(InsnClass, *operands)         # Append instruction\n' +
        'iseq.emit_placeholder(LEN)              # Reserve LEN slots\n' +
        'iseq.patch_at!(pc, InsnClass, offset)   # Fill in placeholder'
      )),
    ),
    instructions: 'branchunless · jump · compile_conditional_node',
    stub: step6Stub,
    testCases: [
      { description: 'true branch', source: 'if 3 < 5; 10; else; 20; end', expected: 10 },
      { description: 'false branch', source: 'if 10 < 5; 10; else; 20; end', expected: 20 },
    ],
    bytecodePreview: `0000 putobject 3\n0002 putobject 5\n0004 opt_lt\n0005 branchunless 2\n0007 putobject 10\n0009 jump 2\n0011 putobject 20\n0013 leave`,
  },

  {
    id: 7,
    title: 'Step 7: Methods & Fibonacci!',
    description: h('div', null,
      h('h2', null, 'Step 7: Method Definition and Calling'),
      h('h3', null, 'VM: Definemethod'),
      h('ul', null,
        h('li', null, 'Register method iseq on current class'),
        h('li', null, 'Use ', h('code', null, 'vm.define_method(mid, iseq)')),
      ),
      h('h3', null, 'VM: OptSendWithoutBlock'),
      h('ul', null,
        h('li', null, h('code', null, 'vm.sendish(cd)'), ' dispatches the method call'),
        h('li', null, 'Sets up a new frame with receiver + arguments'),
        h('li', null, 'The method\'s Leave instruction pushes the return value onto the caller\'s stack'),
      ),
      h('h3', null, 'Compiler: compile_def_node'),
      h('ul', null,
        h('li', null, h('code', null, 'YRuby::Iseq.iseq_new_method(node)'), ' compiles the method body into a new Iseq'),
        h('li', null, 'Emit ', h('code', null, 'Definemethod'), ' + ', h('code', null, 'Putobject(name)'), ' (Ruby convention: ', h('code', null, 'def'), ' returns the method name)'),
      ),
      h('h3', null, 'Compiler: compile_general_call'),
      h('ul', null,
        h('li', null, 'Emit ', h('code', null, 'Putself'), ' as the implicit receiver for receiverless calls'),
        h('li', null, 'Compile each argument, then emit ', h('code', null, 'OptSendWithoutBlock'), ' with a CallData'),
      ),
      h('h3', null, 'Example bytecode: def add(a, b); a + b; end; add(2, 3)'),
      h('pre', null, h('code', null,
        '# Main iseq\n' +
        '0: putself\n' +
        '1: putobject 2\n' +
        '3: putobject 3\n' +
        '5: opt_send_without_block {mid: :add, argc: 2}\n' +
        '7: leave\n' +
        '\n' +
        '# Method iseq for add(a, b)\n' +
        '0: getlocal 1   # a  (params are indexed in reverse)\n' +
        '2: getlocal 0   # b\n' +
        '4: opt_plus\n' +
        '5: leave'
      )),
      h('h3', null, 'Final Goal: fib(10) = 55'),
      h('pre', null, h('code', null,
        'def fib(n)\n  if n < 2\n    n\n  else\n    fib(n - 1) + fib(n - 2)\n  end\nend\nfib(10)  # => 55'
      )),
      h('h3', null, 'API Reference'),
      h('pre', null, h('code', null,
        '# VM\n' +
        'vm.define_method(mid, iseq)              # Register method on current class\n' +
        'vm.sendish(cd)                           # Dispatch method call (CallData)\n' +
        '\n' +
        '# Iseq (instance)\n' +
        'iseq.emit(InsnClass, *operands)          # Append instruction\n' +
        '\n' +
        '# Iseq (class method)\n' +
        'YRuby::Iseq.iseq_new_method(node)       # Compile def body → new Iseq\n' +
        '\n' +
        '# CallData\n' +
        'YRuby::CallData.new(mid: name, argc: n)  # Call descriptor'
      )),
    ),
    instructions: 'definemethod · opt_send_without_block · compile_def_node · compile_general_call',
    stub: step7Stub,
    testCases: [
      {
        description: 'identity(42) → 42',
        source: 'def identity(x); x; end; identity(42)',
        expected: 42,
      },
      {
        description: 'fib(5) → 5',
        source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(5)',
        expected: 5,
      },
      {
        description: 'fib(10) → 55',
        source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(10)',
        expected: 55,
      },
    ],
  },
]
