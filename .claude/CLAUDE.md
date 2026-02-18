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

### Design Pattern: Two Phases

#### Phase A: VM Instructions (Steps 1-7)
Participants implement individual YARV instruction handlers one at a time:
- Step 1: `putobject` (push literal onto stack)
- Step 2: `opt_plus` (addition)
- Step 3: `opt_minus` (subtraction)
- Step 4: `getlocal` / `setlocal` (local variables)
- Step 5: `opt_lt` (less-than comparison)
- Step 6: `branchunless` / `jump` / `leave` (control flow)
- Step 7: `definemethod` / `opt_send_without_block` (method definition & calls)

#### Phase B: Compiler (Steps B1-B5)
Participants implement `compile_node` case statements to convert AST to bytecode:
- B1: `Prism::IntegerNode`
- B2: `Prism::LocalVariableWriteNode` / `Prism::LocalVariableReadNode`
- B3: `Prism::CallNode` (arithmetic: :+, :-, :<)
- B4: `Prism::IfNode` (if/else with forward-reference patching)
- B5: `Prism::DefNode` + general method calls (recursion)

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

### 1. Stack Model: SP/EP Pointer Style

The VM uses a stack with two pointers (same as YRuby):
- **SP (Stack Pointer):** points to the next available slot
- **EP (Environment Pointer):** points to the base of the current frame's local variables

```ruby
vm.stack_push(value)  # stack[sp] = value; sp += 1
vm.stack_pop          # sp -= 1; return stack[sp]
getlocal(index)       # read from stack[ep - index]
setlocal(index)       # write to stack[ep - index]
```

### 2. Branch Instruction Offset (Critical!)

When branching, set `vm.pc = dst - 1` (not `dst`), because the main loop does `pc += 1` after each instruction:

```ruby
# In the execute loop:
loop do
  iseq[pc].call(self)
  self.pc += 1         # ← always incremented
end

# So Jump must compensate:
class Jump < Base
  def call(vm)
    vm.pc = @dst - 1   # ← NOT @dst
  end
end
```

### 3. Code Merging Strategy

Each time "Run Tests" is clicked, ruby.wasm receives concatenated code in this order:

```
1. vm_system.rb           # YRuby, MinRuby, all system instructions defined
2. compiler_system.rb     # Parser, Compiler class
3. participant vm code    # Reopens instruction classes (overrides system)
4. participant compiler   # Reopens compile_node method (Phase B only)
5. test_runner.rb         # ChallengeTestRunner class
6. test invocations       # runner.test(...) calls
```

### 4. Class Reopening in Ruby

Participant code uses Ruby's class reopening pattern to override specific methods:

```ruby
# System defines: class YRuby::Instructions::Putobject < Base; end

# Participant reopens and implements:
class YRuby::Instructions::Putobject < YRuby::Instructions::Base
  def call(vm)
    vm.stack_push(@object)  # ← implementation
  end
end
```

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