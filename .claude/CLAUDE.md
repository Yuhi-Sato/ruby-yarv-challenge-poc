# Ruby YARV Challenge - Project Overview

## Project Goal

Build a browser-based interactive workshop for RubyKaigi LT attendees to learn Ruby's VM (YARV) and compiler by implementing them from scratch. **Final goal:** participants implement a Fibonacci function that runs in their browser.

### Target Outcome
```ruby
def fib(n)
  if n < 2
    n
  else
    fib(n - 1) + fib(n - 2)
  end
end
fib(10)  # => 55
```

---

## Architecture

### Technology Stack
- **Frontend:** React 18 + TypeScript
- **Code Editor:** Monaco Editor (VS Code in browser)
- **Runtime:** ruby.wasm (WebAssembly Ruby in browser)
- **Hosting:** Static (Vercel / GitHub Pages / Cloudflare)
- **No backend server required** - everything runs in the user's browser

### Design Pattern: 7 Combined Steps (VM + Compiler together)

Each step teaches one concept end-to-end: both the VM instruction AND the corresponding compiler case.
Steps accumulate: when running step N, user code from steps 1..N is all merged together.

- Step 1: `putobject` (VM) + `compile_integer_node` (Compiler)
- Step 2: `opt_plus` (VM) + `compile_binary_plus` (Compiler)
- Step 3: `opt_minus` (VM) + `compile_binary_minus` (Compiler)
- Step 4: `getlocal` / `setlocal` (VM) + `compile_local_var_read` / `compile_local_var_write` (Compiler)
- Step 5: `opt_lt` (VM) + `compile_binary_lt` (Compiler)
- Step 6: `branchunless` / `jump` / `leave` (VM) + `compile_if_node` (Compiler)
- Step 7: `definemethod` / `opt_send_without_block` (VM) + `compile_def_node` / `compile_general_call` (Compiler)

### Core UX Flow

```
Participant writes code in Monaco Editor
    ↓
Clicks "Run Tests"
    ↓
JavaScript merges [system code + participant code + test code]
    ↓
ruby.wasm evaluates merged code with `eval()`
    ↓
Results displayed: PASS ✅ / FAIL ❌ per test case
```

---

## Project Structure

```
ruby-yarv-challenge/
├── package.json                     # npm dependencies
├── vite.config.ts                  # Vite + WASM plugins
├── src/
│   ├── main.tsx
│   ├── App.tsx                     # Main component (placeholder)
│   ├── components/                 # React UI components (TO BUILD)
│   │   ├── Layout.tsx              # 3-pane grid (30%|40%|30%)
│   │   ├── TutorialPane.tsx        # Left: step description + bytecode
│   │   ├── EditorPane.tsx          # Center: Monaco Editor
│   │   ├── ResultPane.tsx          # Right: test results + pass/fail
│   │   └── StepNav.tsx             # Top: step navigation
│   ├── hooks/                      # React hooks
│   │   ├── useRubyVM.ts           # ruby.wasm initialization (PARTIAL)
│   │   └── useChallenge.ts        # State management + test execution (TO BUILD)
│   ├── steps/                      # Step configuration data (TO BUILD)
│   │   ├── index.ts
│   │   ├── step1.ts ~ step7.ts
│   │   └── compilerB1.ts ~ compilerB5.ts
│   ├── types.ts                    # TypeScript types (TO BUILD)
│   └── ruby/                       # Ruby source files
│       ├── system/                 # System-provided code (embedded as strings)
│       │   ├── vm_system.rb        # ✓ YRuby, MinRuby, system instructions
│       │   ├── compiler_system.rb  # ✓ Parser + Compiler
│       │   └── test_runner.rb      # ✓ Test framework
│       └── stubs/                  # Participant-facing code skeletons
│           ├── vm_step1_stub.rb    # ✓ Putobject
│           ├── vm_step2_stub.rb    # TO BUILD: OptPlus
│           ├── vm_step3_stub.rb    # TO BUILD: OptMinus
│           ├── vm_step4_stub.rb    # TO BUILD: Getlocal/Setlocal
│           ├── vm_step5_stub.rb    # TO BUILD: OptLt
│           ├── vm_step6_stub.rb    # TO BUILD: Branchunless/Jump/Leave
│           ├── vm_step7_stub.rb    # TO BUILD: Definemethod/OptSendWithoutBlock
│           ├── compiler_b1_stub.rb # TO BUILD: IntegerNode
│           ├── compiler_b2_stub.rb # TO BUILD: LocalVariable*Node
│           ├── compiler_b3_stub.rb # TO BUILD: CallNode(:+,-,:<)
│           ├── compiler_b4_stub.rb # TO BUILD: IfNode
│           └── compiler_b5_stub.rb # TO BUILD: DefNode + general CallNode
└── .claude/
    └── CLAUDE.md (this file)
```

---

## Key Implementation Details

### 1. VM User-Facing API (yruby-aligned)

```ruby
vm.push(value)         # push onto stack
vm.pop                 # pop from stack
vm.topn(n)             # peek without popping (1-indexed)
vm.env_read(index)     # read local variable (internally: stack[ep - index])
vm.env_write(index, v) # write local variable
vm.set_pc(dst)         # set program counter (for branch instructions)
vm.self_value          # the current self object
vm.define_method(mid, iseq)  # register a method on self's class
vm.sendish(cd)         # dispatch a method call (pops recv+args, returns result)
```

### 2. Branch Instruction Offset (IMPORTANT — yruby-aligned)

PC is incremented **BEFORE** instruction execution:

```ruby
# In the execute loop:
loop do
  insn = iseq[pc]
  pc += 1              # ← incremented FIRST
  insn.call(self)      # ← then executed
end

# So Jump uses vm.set_pc(@dst) directly — NO -1 needed:
class Jump < Base
  def call(vm)
    vm.set_pc(@dst)    # ← just @dst, not @dst - 1
  end
end
```

### 3. Code Merging Strategy (Accumulation Model)

Each time "Run Tests" is clicked for step N, ruby.wasm receives:

```
1. vm_system.rb           # VM infrastructure only (no instruction logic)
2. compiler_system.rb     # Compiler scaffold (all methods raise NotImplementedError)
3. test_runner.rb         # ChallengeTestRunner class
4. userCode[1]            # user's step 1 implementation
5. userCode[2]            # user's step 2 implementation (if N >= 2)
...
N. userCode[N]            # user's current step implementation
N+1. test invocations     # runner.test(...) calls
```

Steps depend on each other: failing step 1 will break step 2's tests too.

### 4. Compiler: Method-per-node Pattern

Instead of one `compile_node` case statement, the compiler uses focused methods:

```ruby
class YRuby::Compiler
  def compile_integer_node(node, iseq)    # Step 1 — user implements
  def compile_binary_plus(node, iseq)     # Step 2 — user implements
  def compile_binary_minus(node, iseq)    # Step 3 — user implements
  def compile_local_var_read(node, iseq)  # Step 4 — user implements
  def compile_local_var_write(node, iseq) # Step 4 — user implements
  def compile_binary_lt(node, iseq)       # Step 5 — user implements
  def compile_if_node(node, iseq)         # Step 6 — user implements
  def compile_def_node(node, iseq)        # Step 7 — user implements
  def compile_general_call(node, iseq)    # Step 7 — user implements
end
```

The main `compile_node` dispatch is system-provided and delegates to these methods.

---

## Reference Implementation

This project is based on **yruby** (your own Ruby VM implementation):
- **Source:** `/Users/satouyuhi/YRuby/`
- **Key files:**
  - `lib/yruby.rb` - MinRuby VM with SP/EP stack management
  - `lib/yruby/compiler.rb` - AST to bytecode compiler
  - `lib/yruby/instructions/` - Individual instruction implementations
  - `test/yruby_test.rb` - Test cases

The system Ruby files (`vm_system.rb`, `compiler_system.rb`) are adapted directly from yruby.

---

## Build & Run

### Development
```bash
npm install
npm run dev      # Start Vite dev server on http://localhost:5173
```

### Production Build
```bash
npm run build
npm run preview  # Preview production build locally
```

### Deployment
Static hosting (Vercel, GitHub Pages, Netlify, etc):
```bash
npm run build    # Creates ./dist/
# Deploy ./dist/ to your hosting provider
```

---

## Testing

### Current Status
- ✅ Phase 1: Infrastructure setup
  - Vite project initialized
  - ruby.wasm + Monaco + WASM plugins installed
  - vite.config.ts configured

- ✅ Phase 2: System Ruby files created
  - vm_system.rb (YRuby/MinRuby complete)
  - compiler_system.rb (Parser + Compiler complete)
  - test_runner.rb (Test framework complete)
  - vm_step1_stub.rb (Putobject skeleton started)

- ⏳ Phase 3: TO BUILD NEXT
  - Remaining stub files (vm_step2-7, compiler_b1-5)
  - TypeScript step configuration
  - React UI components
  - useChallenge hook implementation
  - ruby.wasm integration testing

### Verification Steps
1. Run individual steps with correct solutions (from YRuby)
2. Verify all test cases pass
3. Check bytecode disassembly matches expected
4. Test end-to-end: fib(10) = 55 in browser

---

## Important Notes for Implementation

### ruby.wasm Integration
- Module is loaded asynchronously on app startup
- Use `vm.eval(code)` to execute Ruby strings
- Prism gem is pre-required for AST parsing
- Output must be captured via `$challenge_output` global (stdout capture is unreliable)

### Scope (Fib-Only)
These instructions are **NOT** needed:
- `opt_mult`, `opt_div` (not used in fib)
- `opt_eq`, `opt_ge`, `opt_neq` (fib only uses <)
- `putstring`, `send` with blocks (fib doesn't use)

### UI/UX
- 3-pane layout: 30% tutorial | 40% editor | 30% results
- Each step should show:
  - Clear description (left pane)
  - Expected bytecode (left pane)
  - Test Ruby code (left pane)
  - Syntax-highlighted editor (center pane)
  - Test results with PASS/FAIL colors (right pane)
  - Bytecode disassembly (right pane)

---

## Next Steps (Priority Order)

1. **Complete VM stubs** (vm_step2-7)
2. **Complete compiler stubs** (compiler_b1-5)
3. **Create TypeScript step configs** (stepConfig data)
4. **Build React components** (Layout, Editor, Tutorial, Result)
5. **Implement useChallenge hook** (state + test execution)
6. **Test ruby.wasm integration** end-to-end
7. **Fix any bugs** and add error handling
8. **Deploy** to static hosting