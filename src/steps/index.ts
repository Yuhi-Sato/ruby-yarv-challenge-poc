import type { StepConfig } from '../types'

// Import Ruby stubs as raw strings
import vmStep1Stub from '../ruby/stubs/vm_step1_stub.rb?raw'
import vmStep2Stub from '../ruby/stubs/vm_step2_stub.rb?raw'
import vmStep3Stub from '../ruby/stubs/vm_step3_stub.rb?raw'
import vmStep4Stub from '../ruby/stubs/vm_step4_stub.rb?raw'
import vmStep5Stub from '../ruby/stubs/vm_step5_stub.rb?raw'
import vmStep6Stub from '../ruby/stubs/vm_step6_stub.rb?raw'
import vmStep7Stub from '../ruby/stubs/vm_step7_stub.rb?raw'

import compilerB1Stub from '../ruby/stubs/compiler_b1_stub.rb?raw'
import compilerB2Stub from '../ruby/stubs/compiler_b2_stub.rb?raw'
import compilerB3Stub from '../ruby/stubs/compiler_b3_stub.rb?raw'
import compilerB4Stub from '../ruby/stubs/compiler_b4_stub.rb?raw'
import compilerB5Stub from '../ruby/stubs/compiler_b5_stub.rb?raw'

export const STEPS: StepConfig[] = [
  {
    id: 1,
    phase: 'VM',
    title: 'Step 1: Putobject - Push literals onto the stack',
    description: `
## Step 1: Stack Operations

The YARV VM uses a **stack** to manage values during execution.

### What is putobject?
- **putobject** pushes a literal value (integer, boolean, nil) onto the stack
- Example: the code \`42\` compiles to bytecode \`[Putobject(42), Leave]\`
- The VM executes: push 42 onto stack → return stack top

### How does the stack work?
- **SP (Stack Pointer)** tracks the next available slot
- **vm.stack_push(value)**: store value at stack[sp], then increment sp
- **vm.stack_pop()**: decrement sp, return stack[sp]

Your Task: Implement the \`call\` method for Putobject to push @object onto the stack.
    `,
    instructions: 'putobject - push literal value',
    vmStub: vmStep1Stub,
    compilerStub: '',
    testCases: [
      { description: 'Push integer 42', source: '42', expected: 42 },
      { description: 'Push integer 100', source: '100', expected: 100 },
      { description: 'Push 0', source: '0', expected: 0 },
    ],
  },

  {
    id: 2,
    phase: 'VM',
    title: 'Step 2: OptPlus - Add two numbers',
    description: `
## Step 2: Arithmetic - Addition

### What is opt_plus?
- **opt_plus** pops two values, adds them, and pushes the result
- Example: \`1 + 2\` compiles to:
  \`\`\`
  Putobject(1)
  Putobject(2)
  OptPlus
  Leave
  \`\`\`

### Stack Order (CRITICAL!)
- The stack is LIFO (Last In, First Out)
- For \`1 + 2\`: stack holds [1, 2]
- Pop twice: first get 2, then get 1
- Compute: 1 + 2 = 3

Your Task: Implement \`call\` to pop b, pop a, push a + b.
    `,
    instructions: 'opt_plus - addition (+)',
    vmStub: vmStep2Stub,
    compilerStub: '',
    testCases: [
      { description: '1 + 2 = 3', source: '1 + 2', expected: 3 },
      { description: '10 + 5 = 15', source: '10 + 5', expected: 15 },
      { description: '0 + 0 = 0', source: '0 + 0', expected: 0 },
    ],
  },

  {
    id: 3,
    phase: 'VM',
    title: 'Step 3: OptMinus - Subtract numbers',
    description: `
## Step 3: Arithmetic - Subtraction

### What is opt_minus?
- **opt_minus** pops b, pops a, computes a - b, pushes result
- Example: \`10 - 3\` = 7

### Order Matters!
- Pop in LIFO order: b first, then a
- Then compute: a - b (NOT b - a!)

Your Task: Implement \`call\` to pop b, pop a, push a - b.
    `,
    instructions: 'opt_minus - subtraction (-)',
    vmStub: vmStep3Stub,
    compilerStub: '',
    testCases: [
      { description: '10 - 3 = 7', source: '10 - 3', expected: 7 },
      { description: '5 - 5 = 0', source: '5 - 5', expected: 0 },
      { description: '100 - 50 = 50', source: '100 - 50', expected: 50 },
    ],
  },

  {
    id: 4,
    phase: 'VM',
    title: 'Step 4: Local Variables - Getlocal & Setlocal',
    description: `
## Step 4: Local Variable Storage

### EP-Relative Addressing
Local variables are stored in the stack using **EP (Environment Pointer)**:
- EP marks the base of the local variable area
- First local is at: stack[ep - 0]
- Second local is at: stack[ep - 1]
- Nth local is at: stack[ep - N]

### Getlocal
- Read a local variable from stack[ep - index]
- Push it onto the stack

### Setlocal
- Pop a value from the stack
- Store it at stack[ep - index]
- Push the value back (YARV convention)

Example: \`x = 5; x\`
- setlocal 0: store 5 at stack[ep - 0], push 5
- getlocal 0: read stack[ep - 0], push 5

Your Task: Implement both getlocal and setlocal \`call\` methods.
    `,
    instructions: 'getlocal / setlocal - local variables',
    vmStub: vmStep4Stub,
    compilerStub: '',
    testCases: [
      { description: 'x = 5; x', source: 'x = 5; x', expected: 5 },
      { description: 'a = 10; b = 20; a + b', source: 'a = 10; b = 20; a + b', expected: 30 },
    ],
  },

  {
    id: 5,
    phase: 'VM',
    title: 'Step 5: Comparisons - Less Than (OptLt)',
    description: `
## Step 5: Comparison Operators

### What is opt_lt?
- **opt_lt** implements the < (less-than) operator
- Pops b, pops a, pushes boolean result of a < b

### Boolean Values
- Result is \`true\` or \`false\` (Ruby's boolean constants)
- These are then used by branch instructions (\`branchunless\`, \`branchif\`)

Your Task: Implement \`call\` to pop b, pop a, push a < b.
    `,
    instructions: 'opt_lt - less-than comparison',
    vmStub: vmStep5Stub,
    compilerStub: '',
    testCases: [
      { description: '3 < 5 = true', source: '3 < 5', expected: true },
      { description: '10 < 5 = false', source: '10 < 5', expected: false },
      { description: '5 < 5 = false', source: '5 < 5', expected: false },
    ],
  },

  {
    id: 6,
    phase: 'VM',
    title: 'Step 6: Control Flow - Branchunless, Jump, Leave',
    description: `
## Step 6: Conditional Branching

### Branchunless
- Pops a condition value
- If falsy (nil or false), sets vm.pc = dst - 1
- Otherwise, continues to next instruction
- **CRITICAL**: Set pc to dst - 1, NOT dst! The main loop increments pc after each instruction.

### Jump
- Unconditional jump: sets vm.pc = dst - 1
- Used to skip else branches

### Leave
- Throws :leave to exit the execute loop
- Signals end of method/program execution

### Example Bytecode: "if 3 < 5; 10; else; 20; end"
\`\`\`
0: Putobject(3)
1: Putobject(5)
2: OptLt                  # → true
3: Branchunless 5         # condition is true, don't jump
4: Putobject(10)          # (then branch) execute this
5: Jump 6                  # skip else
6: Putobject(20)          # (else branch, skipped)
7: Leave                   # exit
\`\`\`

Your Task: Implement branchunless, jump, and leave.
    `,
    instructions: 'branchunless / jump / leave - control flow',
    vmStub: vmStep6Stub,
    compilerStub: '',
    testCases: [
      { description: 'if true; 10; else; 20; end', source: 'if 3 < 5; 10; else; 20; end', expected: 10 },
      { description: 'if false; 10; else; 20; end', source: 'if 10 < 5; 10; else; 20; end', expected: 20 },
    ],
  },

  {
    id: 7,
    phase: 'VM',
    title: 'Step 7: Methods - Define & Call',
    description: `
## Step 7: Method Definition and Calling

### Definemethod
- Stores a method in the receiver's class method table
- Pushes the method name back onto the stack

### OptSendWithoutBlock
- Pops argc arguments (in reverse order)
- Pops the receiver object
- Looks up the method in receiver.klass.method_table
- Calls vm.invoke_method to execute the method with those args
- Special case: :puts prints to $challenge_output

### Example: "def add(a, b); a + b; end; add(2, 3)"
\`\`\`
0: Definemethod :add, [compiled method code]
1: Putself                 # receiver for method call
2: Putobject(2)            # arg 1
3: Putobject(3)            # arg 2
4: OptSendWithoutBlock :add, 2   # call add(2, 3)
5: Leave
\`\`\`

Your Task: Implement definemethod and opt_send_without_block.
    `,
    instructions: 'definemethod / opt_send_without_block - methods',
    vmStub: vmStep7Stub,
    compilerStub: '',
    testCases: [
      {
        description: 'def add(a,b); a+b; end; add(2,3)',
        source: 'def add(a, b); a + b; end; add(2, 3)',
        expected: 5,
      },
      {
        description: 'def identity(x); x; end; identity(42)',
        source: 'def identity(x); x; end; identity(42)',
        expected: 42,
      },
    ],
  },

  // Compiler steps
  {
    id: 101,
    phase: 'Compiler',
    title: 'Step B1: Compile IntegerNode',
    description: `
## Compiler Phase B1: Integer Literals

Now you implement the **compiler** side!

### IntegerNode
- Represents a literal integer in the source code (e.g., 42)
- Prism AST: \`Prism::IntegerNode(value: 42)\`
- Your job: emit \`Putobject(42)\` instruction

### Pattern
\`\`\`ruby
when Prism::IntegerNode
  iseq.emit(YRuby::Instructions::Putobject.new(node.value))
\`\`\`

Your Task: Add the IntegerNode case to compile_node method.
    `,
    instructions: 'Compile IntegerNode → Putobject',
    vmStub: '',
    compilerStub: compilerB1Stub,
    testCases: [
      { description: '42 compiles correctly', source: '42', expected: 42 },
      { description: '0 compiles correctly', source: '0', expected: 0 },
    ],
  },

  {
    id: 102,
    phase: 'Compiler',
    title: 'Step B2: Compile LocalVariableNodes',
    description: `
## Compiler Phase B2: Local Variables

### LocalVariableWriteNode
- Represents assignment: \`x = value\`
- Prism AST: has node.name and node.value
- Task: compile the value, then emit Setlocal with the variable's index

### LocalVariableReadNode
- Represents reading a variable: \`x\`
- Task: emit Getlocal with the variable's index

### Pattern
\`\`\`ruby
when Prism::LocalVariableWriteNode
  compile_node(node.value, iseq)
  index = iseq.local_table[node.name]
  iseq.emit(YRuby::Instructions::Setlocal.new(index))

when Prism::LocalVariableReadNode
  index = iseq.local_table[node.name]
  iseq.emit(YRuby::Instructions::Getlocal.new(index))
\`\`\`

Your Task: Add both LocalVariable*Node cases to compile_node.
    `,
    instructions: 'Compile LocalVariable nodes → Getlocal/Setlocal',
    vmStub: '',
    compilerStub: compilerB2Stub,
    testCases: [
      { description: 'x = 5; x', source: 'x = 5; x', expected: 5 },
      { description: 'a = 1; b = 2; a + b', source: 'a = 1; b = 2; a + b', expected: 3 },
    ],
  },

  {
    id: 103,
    phase: 'Compiler',
    title: 'Step B3: Compile Binary CallNodes',
    description: `
## Compiler Phase B3: Arithmetic & Comparison Operators

### CallNode for Binary Operators
- Represents: +, -, <, >, ==, !=, <=, >=
- Prism AST: node.name is the operator symbol, node.receiver and node.arguments[0] are operands
- Task: compile receiver, compile argument, emit the appropriate instruction

### Pattern for Addition
\`\`\`ruby
when :+
  compile_node(node.receiver, iseq)
  compile_node(node.arguments.arguments[0], iseq)
  iseq.emit(YRuby::Instructions::OptPlus.new)
\`\`\`

Your Task: Implement :+, :-, and :< cases (other cases are already provided).
    `,
    instructions: 'Compile CallNode binary ops → Opt* instructions',
    vmStub: '',
    compilerStub: compilerB3Stub,
    testCases: [
      { description: '1 + 2 = 3', source: '1 + 2', expected: 3 },
      { description: '10 - 3 = 7', source: '10 - 3', expected: 7 },
      { description: '3 < 5 = true', source: '3 < 5', expected: true },
    ],
  },

  {
    id: 104,
    phase: 'Compiler',
    title: 'Step B4: Compile IfNode with Forward-Reference Patching',
    description: `
## Compiler Phase B4: Conditional Statements

### IfNode
- Represents: \`if condition; then_branch; else; else_branch; end\`
- Challenge: We don't know jump targets until after we've compiled the code!
- Solution: Use reserve_slot and set_slot for forward-reference patching

### Forward-Reference Patching
\`\`\`ruby
1. compile_node(predicate)              # compile condition
2. branchunless_idx = iseq.size
3. iseq.reserve_slot(branchunless_idx)  # placeholder for Branchunless
4. compile_node(then_statements)        # compile then-branch
5. jump_idx = iseq.size
6. iseq.reserve_slot(jump_idx)          # placeholder for Jump
7. else_idx = iseq.size                 # NOW we know else starts here!
8. iseq.set_slot(branchunless_idx, Branchunless(else_idx))  # patch it
9. compile_node(else_statements)        # compile else-branch
10. iseq.set_slot(jump_idx, Jump(iseq.size))  # patch jump to skip else
\`\`\`

Your Task: Implement compile_if_node method.
    `,
    instructions: 'Compile IfNode with forward-reference patching',
    vmStub: '',
    compilerStub: compilerB4Stub,
    testCases: [
      { description: 'if true; 10; else; 20; end', source: 'if 3 < 5; 10; else; 20; end', expected: 10 },
      { description: 'if false; 10; else; 20; end', source: 'if 10 < 5; 10; else; 20; end', expected: 20 },
    ],
  },

  {
    id: 105,
    phase: 'Compiler',
    title: 'Step B5: Compile DefNode & Recursive Calls - FIBONACCI!',
    description: `
## Compiler Phase B5: Methods & Recursion

### DefNode
- Represents: \`def method_name(params); ... end\`
- Task: Use compile_method to create method Iseq, emit Definemethod

### General CallNode (method calls)
- Represents: \`receiver.method(args)\` or \`method(args)\`
- If receiver is nil, emit Putself first
- Compile all arguments
- Emit OptSendWithoutBlock

### Recursion
- When \`fib(n-1)\` is called inside fib, it's a CallNode with receiver=nil
- Compiles to: Putself, (compute n-1), OptSendWithoutBlock(:fib, 1)

### Pattern
\`\`\`ruby
when Prism::DefNode
  method_iseq = compile_method(node)
  iseq.emit(YRuby::Instructions::Definemethod.new(node.name, method_iseq))

# In general method calls:
if node.receiver.nil?
  iseq.emit(YRuby::Instructions::Putself.new)
else
  compile_node(node.receiver, iseq)
end
args = node.arguments&.arguments || []
args.each { |arg| compile_node(arg, iseq) }
iseq.emit(YRuby::Instructions::OptSendWithoutBlock.new(node.name, args.size))
\`\`\`

Your Task: Implement DefNode case and general method call path.

**FINAL TEST: Your implementation should now run fib(10) = 55!**
    `,
    instructions: 'Compile DefNode & general CallNode - enable recursion!',
    vmStub: '',
    compilerStub: compilerB5Stub,
    testCases: [
      { description: 'def identity(x); x; end; identity(42)', source: 'def identity(x); x; end; identity(42)', expected: 42 },
      { description: 'fib(5)', source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(5)', expected: 5 },
      { description: 'fib(10) = 55', source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(10)', expected: 55 },
    ],
  },
]
