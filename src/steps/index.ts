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
    description: `
## Step 1: Push Literals onto the Stack

The YARV VM uses a **stack** to manage values during execution.

### VM: Putobject
- **putobject** pushes a literal value (integer, boolean, nil) onto the stack
- Example: \`42\` compiles to bytecode \`[Putobject(42), Leave]\`
- Stack API: \`vm.push(value)\` stores a value at the top of the stack

### Compiler: compile_integer_node
- \`Prism::IntegerNode\` represents a literal integer (e.g., \`42\`)
- Emit a \`Putobject\` instruction carrying \`node.value\`

### Your Task
Implement both \`Putobject#call\` and \`compile_integer_node\`.
    `,
    instructions: 'putobject · compile_integer_node',
    stub: step1Stub,
    testCases: [
      { description: 'Push integer 42', source: '42', expected: 42 },
      { description: 'Push integer 100', source: '100', expected: 100 },
      { description: 'Push 0', source: '0', expected: 0 },
    ],
    bytecodePreview: `0000 putobject 42
0001 leave`,
  },

  {
    id: 2,
    title: 'Step 2: Addition',
    description: `
## Step 2: Arithmetic — Addition

### VM: OptPlus
- **opt_plus** pops two values, adds them, and pushes the result
- Stack is LIFO: for \`1 + 2\`, pop gets 2 first (b), then 1 (a)
- Compute \`a + b\`, push result

### Compiler: compile_binary_plus
- \`Prism::CallNode\` with \`node.name == :+\`
- \`node.receiver\` is the left operand, \`node.arguments.arguments[0]\` is the right
- Compile both, then emit \`OptPlus\`

### Example Bytecode: \`1 + 2\`
\`\`\`
0000 putobject 1
0001 putobject 2
0002 opt_plus
0003 leave
\`\`\`
    `,
    instructions: 'opt_plus · compile_binary_plus',
    stub: step2Stub,
    testCases: [
      { description: '1 + 2 = 3', source: '1 + 2', expected: 3 },
      { description: '10 + 5 = 15', source: '10 + 5', expected: 15 },
      { description: '0 + 0 = 0', source: '0 + 0', expected: 0 },
    ],
    bytecodePreview: `0000 putobject 1
0001 putobject 2
0002 opt_plus
0003 leave`,
  },

  {
    id: 3,
    title: 'Step 3: Subtraction',
    description: `
## Step 3: Arithmetic — Subtraction

### VM: OptMinus
- **opt_minus** pops b, pops a, computes \`a - b\`, pushes result
- Order matters! a − b, **not** b − a

### Compiler: compile_binary_minus
- Same pattern as \`compile_binary_plus\`, but emit \`OptMinus\`

### Example Bytecode: \`10 - 3\`
\`\`\`
0000 putobject 10
0001 putobject 3
0002 opt_minus
0003 leave
\`\`\`
    `,
    instructions: 'opt_minus · compile_binary_minus',
    stub: step3Stub,
    testCases: [
      { description: '10 - 3 = 7', source: '10 - 3', expected: 7 },
      { description: '5 - 5 = 0', source: '5 - 5', expected: 0 },
      { description: '100 - 50 = 50', source: '100 - 50', expected: 50 },
    ],
    bytecodePreview: `0000 putobject 10
0001 putobject 3
0002 opt_minus
0003 leave`,
  },

  {
    id: 4,
    title: 'Step 4: Local Variables',
    description: `
## Step 4: Local Variable Storage

### EP-Relative Addressing
Local variables are stored in the stack using the **EP (Environment Pointer)**:
- \`env_read(0)\` → first local variable
- \`env_read(1)\` → second local variable
- \`env_read(N)\` → N-th local variable (internally: \`stack[ep - N]\`)

### VM: Getlocal / Setlocal
- **Getlocal**: \`vm.push(vm.env_read(@index))\`
- **Setlocal**: \`vm.env_write(@index, vm.pop)\`

### Compiler: compile_local_var_read / compile_local_var_write
- Look up the variable's index with \`iseq.local_table[node.name]\`
- Emit \`Getlocal.new(index)\` or \`Setlocal.new(index)\`

### Example: \`x = 5; x\`
\`\`\`
locals: x
0000 putobject 5
0001 setlocal 0    # x = 5
0002 getlocal 0    # read x
0003 leave
\`\`\`
    `,
    instructions: 'getlocal · setlocal · compile_local_var_read · compile_local_var_write',
    stub: step4Stub,
    testCases: [
      { description: 'x = 5; x', source: 'x = 5; x', expected: 5 },
      { description: 'a = 10; b = 20; a + b', source: 'a = 10; b = 20; a + b', expected: 30 },
    ],
    bytecodePreview: `locals: x
0000 putobject 5
0001 setlocal 0
0002 getlocal 0
0003 leave`,
  },

  {
    id: 5,
    title: 'Step 5: Comparison',
    description: `
## Step 5: Comparison Operators

### VM: OptLt
- **opt_lt** implements the \`<\` operator
- Pops b, pops a, pushes boolean result of \`a < b\`

### Compiler: compile_binary_lt
- Same pattern as plus/minus, but emit \`OptLt\`

### Example Bytecode: \`3 < 5\`
\`\`\`
0000 putobject 3
0001 putobject 5
0002 opt_lt
0003 leave
\`\`\`

The result (\`true\` or \`false\`) will be consumed by branch instructions in Step 6.
    `,
    instructions: 'opt_lt · compile_binary_lt',
    stub: step5Stub,
    testCases: [
      { description: '3 < 5 = true', source: '3 < 5', expected: true },
      { description: '10 < 5 = false', source: '10 < 5', expected: false },
      { description: '5 < 5 = false', source: '5 < 5', expected: false },
    ],
    bytecodePreview: `0000 putobject 3
0001 putobject 5
0002 opt_lt
0003 leave`,
  },

  {
    id: 6,
    title: 'Step 6: Control Flow',
    description: `
## Step 6: Conditional Branching

### Key Insight: PC increment order
The VM increments PC **before** executing each instruction:
\`\`\`
pc += 1
insn.call(vm)
\`\`\`
So \`vm.set_pc(@dst)\` jumps to instruction \`@dst\` — **no off-by-one adjustment needed!**

### VM: Branchunless
- Pop condition; if **falsy** (nil or false), \`vm.set_pc(@dst)\`

### VM: Jump
- Unconditionally \`vm.set_pc(@dst)\`

### VM: Leave
- \`throw :leave\` to exit the execute loop

### Compiler: compile_if_node
- Use **forward-reference patching** with \`reserve_slot\` / \`set_slot\`
- Reserve placeholders, compile branches, then backpatch with correct destinations

### Example Bytecode: \`if 3 < 5; 10; else; 20; end\`
\`\`\`
0000 putobject 3
0001 putobject 5
0002 opt_lt
0003 branchunless 5    # if false, jump to else (5)
0004 putobject 10      # then branch
0005 jump 6            # skip else
0006 putobject 20      # else branch
0007 leave
\`\`\`
    `,
    instructions: 'branchunless · jump · leave · compile_if_node',
    stub: step6Stub,
    testCases: [
      { description: 'if true branch', source: 'if 3 < 5; 10; else; 20; end', expected: 10 },
      { description: 'if false branch', source: 'if 10 < 5; 10; else; 20; end', expected: 20 },
    ],
    bytecodePreview: `0000 putobject 3
0001 putobject 5
0002 opt_lt
0003 branchunless 5
0004 putobject 10
0005 jump 6
0006 putobject 20
0007 leave`,
  },

  {
    id: 7,
    title: 'Step 7: Methods & Recursion — FIBONACCI!',
    description: `
## Step 7: Method Definition and Calling

### VM: Definemethod
- Store \`@method_iseq\` in the current object's class under \`@method_name\`
- Push \`@method_name\` onto the stack (Ruby convention)
- Use: \`vm.define_method(mid, iseq)\` and \`vm.push(value)\`

### VM: OptSendWithoutBlock
- \`vm.sendish(@cd)\` handles dispatch:
  - Pops argc arguments and the receiver from the stack
  - Looks up the method on the receiver's class
  - Invokes it and returns the result
- Push the result: \`vm.push(result)\`

### Compiler: compile_def_node
- \`compile_method(node)\` (system-provided) compiles the body into a new Iseq
- Emit \`Definemethod.new(node.name, method_iseq)\`

### Compiler: compile_general_call
- If \`node.receiver\` is nil → emit \`Putself\` (e.g., recursive \`fib(n-1)\`)
- Compile each argument
- Build a \`CallData\` and emit \`OptSendWithoutBlock\`

### FINAL TEST: fib(10) = 55 🎉
\`\`\`ruby
def fib(n)
  if n < 2
    n
  else
    fib(n - 1) + fib(n - 2)
  end
end
fib(10)  # => 55
\`\`\`
    `,
    instructions: 'definemethod · opt_send_without_block · compile_def_node · compile_general_call',
    stub: step7Stub,
    testCases: [
      {
        description: 'def identity(x); x; end; identity(42)',
        source: 'def identity(x); x; end; identity(42)',
        expected: 42,
      },
      {
        description: 'fib(5) = 5',
        source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(5)',
        expected: 5,
      },
      {
        description: 'fib(10) = 55',
        source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(10)',
        expected: 55,
      },
    ],
  },
]
