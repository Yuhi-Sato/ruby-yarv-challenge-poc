#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Local test runner for the Ruby YARV Challenge
#
# Usage:
#   ruby scripts/run_challenge.rb          # Run tests for all steps
#   ruby scripts/run_challenge.rb 1        # Run tests for step 1 only
#   ruby scripts/run_challenge.rb 1 3      # Run tests for steps 1 through 3
#
# Steps accumulate: running step N also loads your implementations for steps 1..N-1.
# Edit your implementations in src/ruby/stubs/step{N}.rb, then run this script.

require 'yruby'

ROOT = File.expand_path('..', __dir__)

# ── Test case definitions (mirrors src/steps/index.ts) ──────────────────────

STEPS = [
  {
    id: 1,
    title: 'Step 1: Integer Literals (putobject + compile_integer_node)',
    test_cases: [
      { description: '42 → 42',   source: '42',  expected: 42 },
      { description: '100 → 100', source: '100', expected: 100 },
      { description: '0 → 0',     source: '0',   expected: 0 },
    ],
  },
  {
    id: 2,
    title: 'Step 2: Addition (opt_plus + compile_binary_plus)',
    test_cases: [
      { description: '1 + 2 = 3',   source: '1 + 2',   expected: 3 },
      { description: '10 + 5 = 15', source: '10 + 5',  expected: 15 },
      { description: '0 + 0 = 0',   source: '0 + 0',   expected: 0 },
    ],
  },
  {
    id: 3,
    title: 'Step 3: Subtraction (opt_minus + compile_binary_minus)',
    test_cases: [
      { description: '10 - 3 = 7',    source: '10 - 3',   expected: 7 },
      { description: '5 - 5 = 0',     source: '5 - 5',    expected: 0 },
      { description: '100 - 50 = 50', source: '100 - 50', expected: 50 },
    ],
  },
  {
    id: 4,
    title: 'Step 4: Local Variables (getlocal + setlocal)',
    test_cases: [
      { description: 'x = 5; x → 5',            source: 'x = 5; x',          expected: 5 },
      { description: 'a = 10; b = 20; a + b → 30', source: 'a = 10; b = 20; a + b', expected: 30 },
    ],
  },
  {
    id: 5,
    title: 'Step 5: Comparison (opt_lt + compile_binary_lt)',
    test_cases: [
      { description: '3 < 5 → true',  source: '3 < 5',   expected: true },
      { description: '10 < 5 → false', source: '10 < 5', expected: false },
      { description: '5 < 5 → false',  source: '5 < 5',  expected: false },
    ],
  },
  {
    id: 6,
    title: 'Step 6: Control Flow (branchunless + jump + compile_conditional_node)',
    test_cases: [
      { description: 'true branch',  source: 'if 3 < 5; 10; else; 20; end',  expected: 10 },
      { description: 'false branch', source: 'if 10 < 5; 10; else; 20; end', expected: 20 },
    ],
  },
  {
    id: 7,
    title: 'Step 7: Methods & Fibonacci (definemethod + opt_send_without_block)',
    test_cases: [
      { description: 'identity(42) → 42', source: 'def identity(x); x; end; identity(42)', expected: 42 },
      { description: 'fib(5) → 5',        source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(5)',  expected: 5 },
      { description: 'fib(10) → 55',      source: 'def fib(n); if n < 2; n; else; fib(n - 1) + fib(n - 2); end; end; fib(10)', expected: 55 },
    ],
  },
].freeze

# ── Helpers ──────────────────────────────────────────────────────────────────

GREEN  = "\e[32m"
RED    = "\e[31m"
YELLOW = "\e[33m"
BOLD   = "\e[1m"
RESET  = "\e[0m"

def colorize(text, *codes)
  "#{codes.join}#{text}#{RESET}"
end

def system_file(name)
  File.join(ROOT, 'src', 'ruby', 'system', name)
end

def stub_file(step_id)
  File.join(ROOT, 'src', 'ruby', 'stubs', "step#{step_id}.rb")
end

# ── Argument parsing ─────────────────────────────────────────────────────────

all_ids = STEPS.map { |s| s[:id] }

target_ids =
  case ARGV.length
  when 0
    all_ids
  when 1
    [Integer(ARGV[0])]
  when 2
    (Integer(ARGV[0])..Integer(ARGV[1])).to_a
  else
    warn "Usage: #{$0} [start_step [end_step]]"
    exit 1
  end

invalid = target_ids - all_ids
unless invalid.empty?
  warn "Unknown step(s): #{invalid.join(', ')}. Valid steps: #{all_ids.join(', ')}"
  exit 1
end

# ── Main runner ───────────────────────────────────────────────────────────────

total_passed = 0
total_failed = 0

target_ids.each do |step_id|
  step = STEPS.find { |s| s[:id] == step_id }

  puts
  puts colorize("━" * 60, BOLD)
  puts colorize("  #{step[:title]}", BOLD)
  puts colorize("━" * 60, BOLD)

  # Reload system + stubs fresh for each step so implementations don't bleed
  # across independent step runs.
  load system_file('challenge_patch.rb')
  load system_file('challenge_reset.rb')
  load system_file('test_runner.rb')

  # Accumulate stubs from step 1 up to (and including) this step
  (1..step_id).each do |sid|
    path = stub_file(sid)
    if File.exist?(path)
      load path
    else
      warn colorize("  Warning: stub file not found: #{path}", YELLOW)
    end
  end

  vm     = YRuby.new
  runner = ChallengeTestRunner.new(vm)

  step[:test_cases].each do |tc|
    runner.test(tc[:description], tc[:source], tc[:expected])
  end

  # Print per-test results
  step[:test_cases].each_with_index do |tc, _i|
    report_lines = runner.report.split("\n")
    # Re-run individually to capture per-test info (runner already has results)
  end

  # Use runner's internal results directly
  results = runner.instance_variable_get(:@results)
  results.each do |r|
    if r[:passed]
      puts colorize("  ✓ #{r[:description]}", GREEN)
      total_passed += 1
    else
      puts colorize("  ✗ #{r[:description]}", RED)
      puts colorize("      expected: #{r[:expected]}", RED)
      puts colorize("      got:      #{r[:got] || 'N/A'}", RED)
      puts colorize("      error:    #{r[:error]}", RED) if r[:error]
      total_failed += 1
    end
  end

  if runner.all_passed?
    puts
    puts colorize("  ✅ All tests passed!", GREEN + BOLD)

    # Show bytecode disassembly for the first test case
    begin
      ast   = YRuby::Parser.new.parse(step[:test_cases].first[:source])
      iseq  = YRuby::Iseq.iseq_new_main(ast)
      puts
      puts colorize("  Bytecode disassembly:", BOLD)
      iseq.disasm.each_line { |l| puts "    #{l.chomp}" }
    rescue => e
      puts colorize("  (disassembly error: #{e.message})", YELLOW)
    end
  else
    puts
    puts colorize("  ❌ Some tests failed.", RED + BOLD)
  end
end

# ── Summary ───────────────────────────────────────────────────────────────────

puts
puts colorize("━" * 60, BOLD)
total = total_passed + total_failed
puts colorize("  Results: #{total_passed}/#{total} tests passed", BOLD)
if total_failed == 0
  puts colorize("  🎉 All steps complete!", GREEN + BOLD)
else
  puts colorize("  #{total_failed} test(s) failed — keep going!", YELLOW)
end
puts colorize("━" * 60, BOLD)
puts

exit(total_failed == 0 ? 0 : 1)
