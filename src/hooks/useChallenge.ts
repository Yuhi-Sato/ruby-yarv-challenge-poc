import { useState, useCallback, useEffect } from 'react'
import type { ChallengeState, RunResult, TestResult } from '../types'
import { STEPS } from '../steps'

// Import Ruby system files as raw strings
import challengePatchRb from '../ruby/system/challenge_patch.rb?raw'
import challengeResetRb from '../ruby/system/challenge_reset.rb?raw'
import testRunnerRb from '../ruby/system/test_runner.rb?raw'

const STORAGE_KEY = 'ruby-yarv-challenge-v2'

function loadSavedState(): { currentStep?: number; userCode?: Record<number, string>; completedSteps?: number[] } {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return {}
    return JSON.parse(raw)
  } catch {
    return {}
  }
}

interface UseChallengeOptions {
  vmRef: React.RefObject<any>
}

export function useChallenge({ vmRef }: UseChallengeOptions) {
  const [state, setState] = useState<ChallengeState>(() => {
    const saved = loadSavedState()
    return {
      currentStep: saved.currentStep ?? 0,
      userCode: saved.userCode ?? {},
      completedSteps: saved.completedSteps ?? [],
      lastResult: null,
      isRunning: false,
    }
  })

  // Persist progress to localStorage whenever it changes
  const { currentStep, userCode, completedSteps } = state
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ currentStep, userCode, completedSteps }))
    } catch {
      // Ignore storage errors (private mode, quota exceeded, etc.)
    }
  }, [currentStep, userCode, completedSteps])

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

      // Step 0 (Introduction) has no tests — early return
      if (currentStep.testCases.length === 0) {
        setState(s => ({ ...s, isRunning: false }))
        return
      }

      // Accumulate user code from step 1 to currentStep (skip step 0)
      const stepsUpToCurrent = STEPS
        .filter(s => s.id >= 1 && s.id <= state.currentStep)
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

      // Merge: patch module + challenge reset + test runner + user code + tests
      // Note: yruby gem is already loaded via require 'yruby' in useRubyVM
      const fullCode = [
        challengePatchRb,
        challengeResetRb,
        testRunnerRb,
        accumulatedUserCode,
        `
$challenge_output = ""
$test_output = []
_vm = YRuby.new
runner = ChallengeTestRunner.new(_vm)

${testInvocations}

$test_output << "---START_REPORT---"
$test_output << runner.report
$test_output << "---END_REPORT---"

if runner.all_passed?
  $test_output << "---DISASM_START---"
  begin
    ast = YRuby::Parser.new.parse(${JSON.stringify(currentStep.testCases[0]?.source || '')})
    iseq = YRuby::Iseq.iseq_new_main(ast)
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
        completedSteps: parsedResult.allPassed
          ? s.completedSteps.includes(s.currentStep) ? s.completedSteps : [...s.completedSteps, s.currentStep]
          : s.completedSteps.filter(id => id !== s.currentStep),
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

  const reportLines = report.split('\n')
  for (let i = 0; i < reportLines.length; i++) {
    const line = reportLines[i]
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
      // Check if the next line is an error message
      const nextLine = reportLines[i + 1]
      const errorMsg = nextLine?.trimStart().startsWith('Error:')
        ? nextLine.trim().substring(7).trim()
        : undefined
      if (errorMsg) i++ // skip the error line
      if (match) {
        testResults.push({
          description: match[1],
          passed: false,
          expected: match[2],
          got: match[3],
          error: errorMsg,
        })
      } else {
        testResults.push({
          description: rest,
          passed: false,
          expected: '',
          got: '',
          error: errorMsg,
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
