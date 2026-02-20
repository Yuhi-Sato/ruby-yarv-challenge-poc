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
    userCode: { 1: STEPS[0].stub },
    completedSteps: [],
    lastResult: null,
    isRunning: false,
  })

  const goToStep = useCallback((stepId: number) => {
    const step = STEPS.find(s => s.id === stepId)
    if (step) {
      setState(s => ({
        ...s,
        currentStep: stepId,
        // Initialize with stub only if user hasn't already edited this step
        userCode: s.userCode[stepId] !== undefined
          ? s.userCode
          : { ...s.userCode, [stepId]: step.stub },
        lastResult: null,
      }))
    }
  }, [])

  const updateCode = useCallback((code: string) => {
    setState(s => ({
      ...s,
      userCode: { ...s.userCode, [s.currentStep]: code },
    }))
  }, [])

  const runTests = useCallback(async () => {
    if (!vmRef.current || state.isRunning) {
      return
    }

    setState(s => ({ ...s, isRunning: true }))

    try {
      const currentStep = STEPS.find(s => s.id === state.currentStep)
      if (!currentStep) throw new Error('Step not found')
      if (!vmRef.current) throw new Error('VM not initialized')

      // Accumulate user code from step 1 to currentStep (in order)
      const stepsUpToCurrent = STEPS
        .filter(s => s.id <= state.currentStep)
        .sort((a, b) => a.id - b.id)

      const accumulatedUserCode = stepsUpToCurrent
        .map(s => state.userCode[s.id] ?? s.stub)
        .join('\n\n')

      // Build test invocations
      const testInvocations = currentStep.testCases
        .map(tc => {
          const expectedStr = rubyLiteral(tc.expected)
          return `runner.test(${JSON.stringify(tc.description)}, ${JSON.stringify(tc.source)}, ${expectedStr})`
        })
        .join('\n')

      // Merge: system infrastructure + all user implementations + tests
      const fullCode = [
        vmSystemRb,
        compilerSystemRb,
        testRunnerRb,
        accumulatedUserCode,
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

      const result = vmRef.current.eval(fullCode)
      const output = result.toString()
      const parsedResult = parseRunResult(output)
      setState(s => ({
        ...s,
        lastResult: parsedResult,
        isRunning: false,
        completedSteps: parsedResult.allPassed && !s.completedSteps.includes(s.currentStep)
          ? [...s.completedSteps, s.currentStep]
          : s.completedSteps,
      }))
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
  }, [vmRef, state.userCode, state.currentStep, state.isRunning])

  return {
    state,
    goToStep,
    updateCode,
    runTests,
  }
}

function rubyLiteral(value: any): string {
  if (value === null) return 'nil'
  if (value === true) return 'true'
  if (value === false) return 'false'
  if (typeof value === 'string') return JSON.stringify(value)
  return String(value)
}

function parseRunResult(output: string): RunResult {
  const lines = output.split('\n')

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

  const testResults: TestResult[] = []
  let allPassed = true

  for (const line of report.split('\n')) {
    if (line.startsWith('[PASS]')) {
      testResults.push({
        description: line.substring(6).trim(),
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
