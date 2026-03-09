# Ruby YARV Challenge

A browser-based (and local) interactive workshop where you implement Ruby's VM (YARV) and compiler from scratch.
The final goal is to make a Fibonacci function run on your own YARV implementation.

## Final Goal

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

## Quick Start

### Browser (recommended)

```bash
npm install
npm run dev   # Open http://localhost:5173
```

### Local (Ruby environment)

```bash
gem install yruby          # Install the yruby gem
ruby scripts/run_challenge.rb        # Run tests for all steps
ruby scripts/run_challenge.rb 1      # Run tests for step 1 only
ruby scripts/run_challenge.rb 1 3    # Run tests for steps 1 through 3
```

Edit your implementations in `src/ruby/stubs/`, then run the script to check your work.

---

## Tutorial

Each step has you implement a **VM instruction** and the matching **compiler method** together.
Steps accumulate: running step N loads your implementations for steps 1 through N.

---

### Step 1: Integer Literals — Push a value onto the stack

**VM instruction: `putobject`**

YARV is a **stack machine**. Every value flows through a fixed-size stack.

- `putobject` pushes a literal value onto the stack
- Use `vm.push(value)` to push

**Compiler: `compile_integer_node`**

- `Prism::IntegerNode` represents an integer literal (e.g. `42`)
- `node.value` holds the integer — emit `iseq.emit(Putobject, node.value)`

**Expected bytecode for `42`:**

```
0000 putobject 42
0002 leave
```

**Test cases:**

| Input | Expected |
|-------|----------|
| `42`  | `42`     |
| `100` | `100`    |
| `0`   | `0`      |

**Hints:**
1. `vm.push(x)` places a value on top of the stack. `iseq.emit(InsnClass, *operands)` appends an instruction to the instruction sequence.
2. Putobject: `vm.push(value)` — Compiler: `iseq.emit(YRuby::Insns::Putobject, node.value)`

---

### Step 2: Addition

**VM instruction: `opt_plus`**

- `opt_plus` pops two values and pushes their sum
- Stack peek: `vm.topn(2)` = left operand (a), `vm.topn(1)` = right operand (b)
- Pop both, then push `a + b`

**Compiler: `compile_binary_plus`**

- The operands are already compiled by `compile_call_node_dispatch`
- You only need to emit `iseq.emit(YRuby::Insns::OptPlus)`

**Expected bytecode for `1 + 2`:**

```
0000 putobject 1
0002 putobject 2
0004 opt_plus
0005 leave
```

**Test cases:**

| Input    | Expected |
|----------|----------|
| `1 + 2`  | `3`      |
| `10 + 5` | `15`     |
| `0 + 0`  | `0`      |

**Hints:**
1. For `1 + 2`, the stack before `opt_plus` is `[1, 2]`. `topn(2)=1` (left), `topn(1)=2` (right). Pop both, push their sum.
2. OptPlus: `b = vm.pop; a = vm.pop; vm.push(a + b)` — Compiler: `iseq.emit(YRuby::Insns::OptPlus)`

---

### Step 3: Subtraction

**VM instruction: `opt_minus`**

- `opt_minus`: peek `topn(2)` = a (left), `topn(1)` = b (right), push `a − b`
- **Order matters!** Compute `a − b`, not `b − a`

**Compiler: `compile_binary_minus`**

- Same pattern as `compile_binary_plus`, but emit `OptMinus`

**Expected bytecode for `10 - 3`:**

```
0000 putobject 10
0002 putobject 3
0004 opt_minus
0005 leave
```

**Test cases:**

| Input      | Expected |
|------------|----------|
| `10 - 3`   | `7`      |
| `5 - 5`    | `0`      |
| `100 - 50` | `50`     |

**Hints:**
1. Same stack pattern as Step 2, but compute `a - b`. `topn(2)` is the left operand. Order matters!
2. OptMinus: `b = vm.pop; a = vm.pop; vm.push(a - b)` — Compiler: `iseq.emit(YRuby::Insns::OptMinus)`

---

### Step 4: Local Variables

**EP-relative addressing**

Locals live in the stack, addressed via the **EP (Environment Pointer)**:

- `env_read(-idx)` → read local at index idx
- `env_write(-idx, val)` → write local at index idx
- Internally: `stack[ep + (-idx)]`

**VM instructions: `getlocal` / `setlocal`**

- **Getlocal(idx)**: read `env_read(-idx)`, push it
- **Setlocal(idx)**: pop a value, write it with `env_write(-idx, val)`

**Compiler: `compile_local_var_read` / `compile_local_var_write`**

- Look up the index: `@index_lookup_table[node.name]`
- For write: compile the value, emit `Dup`, then emit `Setlocal`

**Expected bytecode for `x = 5; x`:**

```
0000 putobject 5
0002 dup
0003 setlocal 0
0005 getlocal 0
0007 leave
```

**Test cases:**

| Input                  | Expected |
|------------------------|----------|
| `x = 5; x`             | `5`      |
| `a = 10; b = 20; a + b` | `30`    |

**Hints:**
1. Getlocal pushes `env_read(-idx)` onto the stack. Setlocal pops and stores with `env_write(-idx, val)`. In the compiler, `@index_lookup_table[node.name]` gives the variable index.
2. Getlocal: `vm.push(vm.env_read(-idx))` — Setlocal: `vm.env_write(-idx, vm.pop)` — compile_local_var_write: compile `node.value`, then emit `Dup`, then emit `Setlocal` with the index

---

### Step 5: Comparison — Less Than

**VM instruction: `opt_lt`**

- `opt_lt`: peek `topn(2)` = a, `topn(1)` = b, push `a < b`
- Same stack pattern as `opt_plus` / `opt_minus`

**Compiler: `compile_binary_lt`**

- Same pattern as `compile_binary_plus`, but emit `OptLt`

The boolean result (`true` or `false`) will be consumed by the branch instructions in Step 6.

**Expected bytecode for `3 < 5`:**

```
0000 putobject 3
0002 putobject 5
0004 opt_lt
0005 leave
```

**Test cases:**

| Input    | Expected |
|----------|----------|
| `3 < 5`  | `true`   |
| `10 < 5` | `false`  |
| `5 < 5`  | `false`  |

**Hints:**
1. Same stack pattern as `opt_plus` / `opt_minus`, but push the boolean result of `a < b`.
2. OptLt: `b = vm.pop; a = vm.pop; vm.push(a < b)` — Compiler: `iseq.emit(YRuby::Insns::OptLt)`

---

### Step 6: Control Flow — Conditional Branching

**Key insight: PC and offsets**

The VM advances PC by instruction length **before** executing:

```
insn = iseq.fetch(pc)
pc += insn::LEN    ← advanced first
insn.call(vm, ...) ← then executed
```

Branch instructions use **relative offsets**: `vm.add_pc(dst)` adjusts PC by `dst` from the current position.

**VM instruction: `branchunless`**

- Pop condition; if **falsy** (nil or false), call `vm.add_pc(dst)`

**VM instruction: `jump`**

- Unconditionally call `vm.add_pc(dst)`

**Compiler: `compile_conditional_node`**

Use **forward-reference patching**: reserve space first, fill in jump offsets once target positions are known.

```ruby
# 1. Compile the predicate
compile_node(iseq, node.predicate)

# 2. Reserve a Branchunless slot
br_pc = iseq.size
iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)

# 3. Compile the then-branch
compile_node(iseq, node.statements)

# 4. Reserve a Jump slot (to skip the else-branch)
then_end_pc = iseq.size
iseq.emit_placeholder(YRuby::Insns::Jump::LEN)

# 5. Patch Branchunless → else label
else_label = iseq.size
br_offset = else_label - (br_pc + Branchunless::LEN)
iseq.patch_at!(br_pc, Branchunless, br_offset)

# 6. Compile the else-branch
# node.consequent is ElseNode → compile_node(iseq, node.consequent.statements)
# node.consequent is IfNode  → compile_conditional_node(iseq, node.consequent)

# 7. Patch Jump → end label
end_label = iseq.size
jump_offset = end_label - (then_end_pc + Jump::LEN)
iseq.patch_at!(then_end_pc, Jump, jump_offset)
```

**Expected bytecode for `if 3 < 5; 10; else; 20; end`:**

```
0000 putobject 3
0002 putobject 5
0004 opt_lt
0005 branchunless 2
0007 putobject 10
0009 jump 2
0011 putobject 20
0013 leave
```

**Test cases:**

| Input                             | Expected |
|-----------------------------------|----------|
| `if 3 < 5; 10; else; 20; end`    | `10`     |
| `if 10 < 5; 10; else; 20; end`   | `20`     |

**Hints:**
1. Branchunless: pop the condition, call `vm.add_pc(dst)` only if it was falsy. Jump: always call `vm.add_pc(dst)`. Follow the 7-step patching algorithm above exactly.
2. Branchunless: `val = vm.pop; vm.add_pc(dst) unless val` — Jump: `vm.add_pc(dst)` — Compiler: implement the 7-step algorithm above

---

### Step 7: Methods & Fibonacci!

**VM instruction: `definemethod`**

- Registers a method's iseq on the current class
- Use `vm.define_method(mid, iseq)`

**VM instruction: `opt_send_without_block`**

- `vm.sendish(cd)` dispatches the method call
- Sets up a new frame with receiver + arguments
- The method's `leave` instruction pushes the return value

**Compiler: `compile_def_node`**

- `YRuby::Iseq.iseq_new_method(node)` compiles the method body into an iseq
- Emit `Definemethod` + `Putobject(name)`

**Compiler: `compile_general_call`**

- Emit `Putself` (implicit receiver for receiverless calls)
- Compile arguments, build `CallData`, emit `OptSendWithoutBlock`

**Final goal:**

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

**Test cases:**

| Input | Expected |
|-------|----------|
| `def identity(x); x; end; identity(42)` | `42` |
| `def fib(n); if n < 2; n; else; fib(n-1) + fib(n-2); end; end; fib(5)` | `5` |
| `def fib(n); if n < 2; n; else; fib(n-1) + fib(n-2); end; end; fib(10)` | `55` |

**Hints:**
1. Definemethod: `vm.define_method(mid, iseq)` — OptSendWithoutBlock: `vm.sendish(cd)` — compile_def_node: create a method iseq with `YRuby::Iseq.iseq_new_method(node)`, then emit `Definemethod` and `Putobject(node.name)`.
2. compile_general_call: emit `Putself`, compile each argument with `compile_node`, then emit `OptSendWithoutBlock` with `YRuby::CallData.new(mid: node.name, argc: node.arguments.arguments.length)`

---

## VM API Reference

```ruby
vm.push(x)                  # Push value onto the stack
vm.pop                      # Pop and return the top value
vm.topn(n)                  # Peek at the nth value from the top (1 = top)
vm.env_read(-idx)           # Read a local variable at index idx
vm.env_write(-idx, v)       # Write a local variable at index idx
vm.add_pc(offset)           # Adjust PC by a relative offset (for branches)
vm.define_method(m, iseq)   # Register a method on the current class
vm.sendish(cd)              # Dispatch a method call
```

## Iseq API Reference

```ruby
iseq.emit(InsnClass, *operands)           # Append an instruction
iseq.emit_placeholder(InsnClass::LEN)     # Reserve space for a forward reference
iseq.patch_at!(pc, InsnClass, offset)     # Fill in a placeholder with the real instruction
iseq.size                                 # Current iseq size (for computing jump offsets)

YRuby::Iseq.iseq_new_method(node)         # Create a method iseq from a DefNode
```

---

## Project Structure

```
src/
├── ruby/
│   ├── system/
│   │   ├── challenge_patch.rb    # Prepends Patch module to YRuby::Compile
│   │   ├── challenge_reset.rb    # Stubs out implementation methods with NotImplementedError
│   │   └── test_runner.rb        # ChallengeTestRunner class
│   └── stubs/                    # Files you implement
│       ├── step1.rb              # Putobject + compile_integer_node
│       ├── step2.rb              # OptPlus + compile_binary_plus
│       ├── step3.rb              # OptMinus + compile_binary_minus
│       ├── step4.rb              # Getlocal/Setlocal + compile_local_var_read/write
│       ├── step5.rb              # OptLt + compile_binary_lt
│       ├── step6.rb              # Branchunless/Jump + compile_conditional_node
│       └── step7.rb              # Definemethod/OptSendWithoutBlock + compile_def_node/compile_general_call
└── ...

scripts/
└── run_challenge.rb              # Local CLI test runner
```

---

## Local Setup

### Requirements

- Ruby 3.3 or later (Prism is bundled)
- `yruby` gem

### Setup

```bash
# Clone the repository
git clone https://github.com/Yuhi-Sato/ruby-yarv-challenge-poc
cd ruby-yarv-challenge-poc

# Install the yruby gem
gem install yruby
```

### Running tests

```bash
# Test step 1
ruby scripts/run_challenge.rb 1

# Test steps 1 through 3
ruby scripts/run_challenge.rb 1 3

# Test all steps
ruby scripts/run_challenge.rb
```

### Workflow

1. Open `src/ruby/stubs/step1.rb`
2. Replace the `TODO` comment with your implementation
3. Run `ruby scripts/run_challenge.rb 1`
4. Once all tests pass, move to the next step

---

## Browser Setup

```bash
npm install
npm run dev      # Start dev server at http://localhost:5173
npm run build    # Production build → ./dist/
npm run preview  # Preview the production build locally
```

Deploy `./dist/` to any static host (Vercel, GitHub Pages, Cloudflare Pages, etc.).

---

## Architecture

### Accumulation Model

When you run tests for step N, your implementations for steps 1 through N are all merged together:

```
challenge_patch.rb   # Prepend Patch module to YRuby::Compile
    ↓
challenge_reset.rb   # Override implementation methods with NotImplementedError
    ↓
step1.rb             # Your Step 1 implementation (re-overrides)
step2.rb             # Your Step 2 implementation
...
stepN.rb             # Your current step implementation
    ↓
Run tests
```

### References

- **yruby gem**: https://github.com/Yuhi-Sato/yruby
- **Ruby WASM**: https://github.com/ruby/ruby.wasm
