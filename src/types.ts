// TypeScript type definitions for Ruby YARV Challenge

export type VMStatus = 'loading' | 'ready' | 'error'
export type Phase = 'A' | 'B'
export type StepPhase = 'VM' | 'Compiler'

export interface TestCase {
  description: string
  source: string
  expected: number | string | boolean | null
}

export interface StepConfig {
  id: number
  phase: StepPhase
  title: string
  description: string // Markdown
  instructions: string // Instructions introduced in this step
  vmStub: string // Participant-editable VM code
  compilerStub: string // Participant-editable compiler code
  testCases: TestCase[]
  bytecodePreview?: string // Expected bytecode for tutorial pane
}

export interface TestResult {
  description: string
  passed: boolean
  expected: string
  got: string
  error?: string
}

export interface RunResult {
  passed: boolean
  allPassed: boolean
  bytecodeDisasm: string
  testResults: TestResult[]
  errorMessage: string | null
}

export interface ChallengeState {
  currentStep: number
  vmCode: string
  compilerCode: string
  lastResult: RunResult | null
  isRunning: boolean
}
