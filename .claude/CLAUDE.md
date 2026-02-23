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
- **Frontend:** React 19 + TypeScript
- **Code Editor:** Monaco Editor (VS Code in browser)
- **Runtime:** ruby.wasm (`@ruby/4.0-wasm-wasi`) — Ruby 4.0 WebAssembly in browser
- **Build:** Vite 7 + vite-plugin-wasm + vite-plugin-top-level-await
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
- Step 6: `branchunless` / `jump` (VM) + `compile_conditional_node` (Compiler)
- Step 7: `definemethod` / `opt_send_without_block` (VM) + `compile_def_node` / `compile_general_call` (Compiler)

### Core UX Flow

```
Participant writes code in Monaco Editor
    ↓
Clicks "Run Tests" (or Ctrl+Enter / Cmd+Enter)
    ↓
JavaScript merges [yruby bundle + challenge reset + user code + test code]
    ↓
ruby.wasm evaluates merged code with vm.eval()
    ↓
Results displayed: PASS ✅ / FAIL ❌ per test case
```

---

## Project Structure

```
ruby-yarv-challenge-poc/
├── package.json
├── vite.config.ts                  # Vite + WASM plugins
├── index.html
├── public/
│   └── ruby+yruby.wasm            # Pre-built WASM binary
├── rubies/                         # Ruby source for WASM build
├── scripts/                        # Build scripts
├── src/
│   ├── main.tsx
│   ├── App.tsx                     # Main component (loading/error/3-pane UI)
│   ├── App.css
│   ├── types.ts                    # TypeScript types
│   ├── components/
│   │   ├── Layout.tsx / Layout.css         # 3-pane grid
│   │   ├── TutorialPane.tsx / TutorialPane.css  # Left: step description + bytecode
│   │   ├── EditorPane.tsx / EditorPane.css      # Center: Monaco Editor
│   │   ├── ResultPane.tsx / ResultPane.css      # Right: test results + pass/fail
│   │   └── StepNav.tsx / StepNav.css            # Top: step navigation
│   ├── hooks/
│   │   ├── useRubyVM.ts            # ruby.wasm initialization (loads + requires prism)
│   │   └── useChallenge.ts         # State management + test execution (accumulation model)
│   ├── steps/
│   │   └── index.ts                # All 7 StepConfig entries (JSX descriptions, test cases)
│   └── ruby/
│       ├── system/
│       │   ├── yruby_bundle.rb     # Full yruby gem bundled for browser (VM, compiler, instructions)
│       │   ├── challenge_reset.rb  # Overrides participant methods with NotImplementedError
│       │   └── test_runner.rb      # ChallengeTestRunner class
│       └── stubs/                  # Participant-facing code skeletons (combined VM + compiler)
│           ├── step1.rb            # Putobject + compile_integer_node
│           ├── step2.rb            # OptPlus + compile_binary_plus
│           ├── step3.rb            # OptMinus + compile_binary_minus
│           ├── step4.rb            # Getlocal/Setlocal + compile_local_var_read/write
│           ├── step5.rb            # OptLt + compile_binary_lt
│           ├── step6.rb            # Branchunless/Jump + compile_conditional_node
│           └── step7.rb            # Definemethod/OptSendWithoutBlock + compile_def_node/compile_general_call
└── .claude/
    └── CLAUDE.md (this file)
```

---

## Key Implementation Details

### 1. yruby Gem Architecture

The project bundles the **yruby gem** (`yruby_bundle.rb`) which provides a fully working Ruby VM. The `challenge_reset.rb` file then overrides specific methods with `NotImplementedError`, and participant stubs re-override those methods.

```
yruby_bundle.rb          # Full working VM + compiler
    ↓
challenge_reset.rb        # Stub out methods participants must implement
    ↓
step1.rb .. stepN.rb      # Participant's implementations (re-override)
```

### 2. Instruction Pattern (Class Methods)

Instructions are class methods on `YRuby::Insns::*`, not instance methods:

```ruby
class YRuby::Insns::Putobject
  def self.call(vm, value)
    vm.push(value)
  end
end

class YRuby::Insns::OptPlus
  def self.call(vm)
    a, b = vm.pop, vm.pop
    vm.push(a + b)
  end
end
```

### 3. Compiler Pattern (Method-per-node on YRuby::Compile)

The compiler class is `YRuby::Compile` (not `YRuby::Compiler`). Method signature is `(iseq, node)` — iseq first:

```ruby
class YRuby::Compile
  def compile_integer_node(iseq, node)    # Step 1
  def compile_binary_plus(iseq, node)     # Step 2
  def compile_binary_minus(iseq, node)    # Step 3
  def compile_local_var_read(iseq, node)  # Step 4
  def compile_local_var_write(iseq, node) # Step 4
  def compile_binary_lt(iseq, node)       # Step 5
  def compile_conditional_node(iseq, node) # Step 6
  def compile_def_node(iseq, node)        # Step 7
  def compile_general_call(iseq, node)    # Step 7
end
```

The main `compile_node` dispatch is system-provided and delegates to these methods.

### 4. VM User-Facing API

```ruby
vm.push(x)              # Push value onto stack
vm.pop                  # Pop and return top value
vm.topn(n)              # Peek nth from top (1 = top)
vm.env_read(-idx)       # Read local variable at idx
vm.env_write(-idx, v)   # Write local variable at idx
vm.add_pc(offset)       # Adjust PC by relative offset (for branches)
vm.define_method(m, iseq)   # Register method on class
vm.sendish(cd)          # Dispatch method call
```

### 5. Branch Instructions — Relative Offsets (IMPORTANT)

PC advances by instruction LEN **BEFORE** execution. Branch instructions use **relative offsets**, not absolute positions:

```ruby
# In the execute loop:
#   insn_class = iseq.fetch(pc)
#   len = insn_class::LEN
#   operands = fetch operands...
#   pc += len             ← advanced first
#   insn_class.call(vm, *operands) ← then executed

# So branch instructions use vm.add_pc(offset):
class YRuby::Insns::Jump
  def self.call(vm, dst)
    vm.add_pc(dst)        # relative offset from current position
  end
end

class YRuby::Insns::Branchunless
  def self.call(vm, dst)
    val = vm.topn(1)
    vm.pop
    vm.add_pc(dst) unless val
  end
end
```

The compiler uses `emit_placeholder` / `patch_at!` for forward-reference patching:
```ruby
# branchunless_pc = iseq.size
# iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)
# ... compile branches ...
# offset = target_pc - (branchunless_pc + Branchunless::LEN)
# iseq.patch_at!(branchunless_pc, Branchunless, offset)
```

### 6. Code Merging Strategy (Accumulation Model)

Each time "Run Tests" is clicked for step N, ruby.wasm receives:

```
1. yruby_bundle.rb        # Full yruby gem (working VM + compiler)
2. challenge_reset.rb     # Stub out participant methods with NotImplementedError
3. test_runner.rb         # ChallengeTestRunner class
4. userCode[1]            # user's step 1 implementation (re-overrides)
5. userCode[2]            # user's step 2 implementation (if N >= 2)
...
N+3. userCode[N]          # user's current step implementation
N+4. test invocations     # runner.test(...) calls + output capture
```

Steps depend on each other: failing step 1 will break step 2's tests too.

---

## Reference Implementation

This project is based on **yruby** (Ruby VM gem):
- **GitHub:** https://github.com/Yuhi-Sato/yruby
- **Bundled as:** `src/ruby/system/yruby_bundle.rb` (all gem files concatenated)

---

## Build & Run

### Development
```bash
npm install
npm run dev      # Start Vite dev server on http://localhost:5173
```

### Production Build
```bash
npm run build    # tsc + vite build → ./dist/
npm run preview  # Preview production build locally
```

### Deployment
Static hosting (Vercel, GitHub Pages, Netlify, etc):
```bash
npm run build    # Creates ./dist/
# Deploy ./dist/ to your hosting provider
```

---

## Current Status

All core features are implemented:
- ✅ Vite + ruby.wasm + Monaco infrastructure
- ✅ yruby gem bundled for browser (`yruby_bundle.rb`)
- ✅ Challenge reset system (`challenge_reset.rb`)
- ✅ All 7 step stubs (`step1.rb` ~ `step7.rb`)
- ✅ Step configurations with JSX descriptions and test cases (`steps/index.ts`)
- ✅ React UI components (Layout, TutorialPane, EditorPane, ResultPane, StepNav)
- ✅ useChallenge hook with accumulation model
- ✅ useRubyVM hook (Ruby 4.0 + Prism)

---

## Important Notes

### ruby.wasm Integration
- Module is loaded asynchronously on app startup via `useRubyVM`
- Uses `@ruby/4.0-wasm-wasi` (Ruby 4.0) with `@ruby/wasm-wasi` DefaultRubyVM
- Prism is built into Ruby 4.0 — required on init for AST parsing
- Output captured via `$test_output` array joined with newlines

### Scope (Fib-Only)
These instructions are **NOT** needed:
- `opt_mult`, `opt_div` (not used in fib)
- `opt_eq`, `opt_ge`, `opt_neq` (fib only uses <)
- `putstring`, `send` with blocks (fib doesn't use)

### UI/UX
- 3-pane layout: tutorial | editor | results
- Each step shows:
  - Description with VM + compiler explanation (left pane)
  - Expected bytecode preview (left pane)
  - Syntax-highlighted Monaco editor (center pane)
  - Test results with PASS/FAIL colors (right pane)
  - Bytecode disassembly on all-pass (right pane)
- Keyboard shortcut: Ctrl+Enter / Cmd+Enter to run tests
