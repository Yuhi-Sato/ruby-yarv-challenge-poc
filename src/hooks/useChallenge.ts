import { useState, useCallback } from 'react'
import type { ChallengeState, RunResult, TestResult } from '../types'
import { STEPS } from '../steps'

// Import Ruby system files as raw strings
import vmSystemRb from '../ruby/system/vm_system.rb?raw'
import compilerSystemRb from '../ruby/system/compiler_system.rb?raw'
import testRunnerRb from '../ruby/system/test_runner.rb?raw'

interface UseChallengeOptions {
  vmRef: React.RefObject<any>
}

export function useChallenge({ vmRef }: UseChallengeOptions) {
  const [state, setState] = useState<ChallengeState>({
    currentStep: 1,
    vmCode: STEPS[0].vmStub,
    compilerCode: STEPS[0].compilerStub,
    lastResult: null,
    isRunning: false,
  })

  const goToStep = useCallback((stepId: number) => {
    const step = STEPS.find(s => s.id === stepId)
    if (step) {
      setState(s => ({
        ...s,
        currentStep: stepId,
        vmCode: step.vmStub,
        compilerCode: step.compilerStub,
        lastResult: null,
      }))
    }
  }, [])

  const updateCode = useCallback((code: string) => {
    const currentStep = STEPS.find(s => s.id === state.currentStep)
    if (currentStep) {
      setState(s => ({
        ...s,
        [currentStep.phase === 'VM' ? 'vmCode' : 'compilerCode']: code,
      }))
    }
  }, [state.currentStep])

  const runTests = useCallback(async () => {
    if (!vmRef.current || state.isRunning) {
      return
    }

    setState(s => ({ ...s, isRunning: true }))

    try {
      const currentStep = STEPS.find(s => s.id === state.currentStep)
      if (!currentStep) {
        throw new Error('Step not found')
      }

      if (!vmRef.current) {
        throw new Error('VM not initialized')
      }

      // Build test code
      const testInvocations = currentStep.testCases
        .map(tc => {
          const expectedStr = rubyLiteral(tc.expected)
          return `runner.test(${JSON.stringify(tc.description)}, ${JSON.stringify(tc.source)}, ${expectedStr})`
        })
        .join('\n')

      // Merge all code: system + participant + tests
      const fullCode = [
        vmSystemRb,
        compilerSystemRb,
        testRunnerRb,
        state.vmCode,
        state.compilerCode,
        `
$challenge_output = ""
$test_output = []
parser = YRuby::Parser.new
compiler = YRuby::Compiler.new
_vm = MinRuby.new(parser, compiler)
runner = ChallengeTestRunner.new(_vm)

${testInvocations}

$test_output << "---START_REPORT---"
$test_output << runner.report
$test_output << "---END_REPORT---"

if runner.all_passed?
  $test_output << "---DISASM_START---"
  begin
    ast = parser.parse(${JSON.stringify(currentStep.testCases[0]?.source || '')})
    iseq = compiler.compile(ast)
    $test_output << iseq.disasm
  rescue => e
    $test_output << "Error: #{e.message}"
  end
  $test_output << "---DISASM_END---"
end

$test_output.join("\\n")
        `,
      ].join('\n\n')

      // Execute in ruby.wasm
      const result = vmRef.current.eval(fullCode)
      const output = result.toString()

      // Parse output
      const parsedResult = parseRunResult(output)
      setState(s => ({ ...s, lastResult: parsedResult, isRunning: false }))
    } catch (e) {
      console.error('Test execution error:', e)
      const errorMsg = e instanceof Error ? e.message : String(e)
      const errorResult: RunResult = {
        passed: false,
        allPassed: false,
        bytecodeDisasm: '',
        testResults: [],
        errorMessage: errorMsg,
      }
      setState(s => ({ ...s, lastResult: errorResult, isRunning: false }))
    }
  }, [vmRef, state.vmCode, state.compilerCode, state.currentStep, state.isRunning])

  return {
    state,
    goToStep,
    updateCode,
    runTests,
  }
}

/**
 * Convert a value to Ruby literal
 */
function rubyLiteral(value: any): string {
  if (value === null) return 'nil'
  if (value === true) return 'true'
  if (value === false) return 'false'
  if (typeof value === 'string') return JSON.stringify(value)
  return String(value)
}

/**
 * Parse the test report output from ruby.wasm
 */
function parseRunResult(output: string): RunResult {
  const lines = output.split('\n')

  // Find report section
  let reportStart = -1
  let reportEnd = -1
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('---START_REPORT---')) reportStart = i
    if (lines[i].includes('---END_REPORT---')) reportEnd = i
  }

  let report = ''
  if (reportStart >= 0 && reportEnd > reportStart) {
    report = lines.slice(reportStart + 1, reportEnd).join('\n')
  }

  // Find bytecode section
  let bytecodeDisasm = ''
  let disasmStart = -1
  let disasmEnd = -1
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('---DISASM_START---')) disasmStart = i
    if (lines[i].includes('---DISASM_END---')) disasmEnd = i
  }

  if (disasmStart >= 0 && disasmEnd > disasmStart) {
    bytecodeDisasm = lines.slice(disasmStart + 1, disasmEnd).join('\n')
  }

  // Parse test results
  const testResults: TestResult[] = []
  const reportLines = report.split('\n')
  let allPassed = true

  for (const line of reportLines) {
    if (line.startsWith('[PASS]')) {
      const description = line.substring(6).trim()
      testResults.push({
        description,
        passed: true,
        expected: '',
        got: '',
      })
    } else if (line.startsWith('[FAIL]')) {
      allPassed = false
      const rest = line.substring(6).trim()
      const match = rest.match(/(.+): expected=(.+), got=(.+)/)
      if (match) {
        testResults.push({
          description: match[1],
          passed: false,
          expected: match[2],
          got: match[3],
        })
      } else {
        testResults.push({
          description: rest,
          passed: false,
          expected: '',
          got: '',
        })
      }
    }
  }

  return {
    passed: allPassed,
    allPassed,
    bytecodeDisasm,
    testResults,
    errorMessage: null,
  }
}
