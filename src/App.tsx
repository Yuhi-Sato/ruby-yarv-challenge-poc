import { useEffect, useRef } from 'react'
import { useRubyVM } from './hooks/useRubyVM'
import { useChallenge } from './hooks/useChallenge'
import { Layout } from './components/Layout'
import { StepNav } from './components/StepNav'
import { TutorialPane } from './components/TutorialPane'
import { EditorPane } from './components/EditorPane'
import { ResultPane } from './components/ResultPane'
import { STEPS } from './steps'
import './App.css'

const VM_API_LINES = [
  'vm.push(x)            # Push value onto stack',
  'vm.pop                # Pop and return top value',
  'vm.topn(n)            # Peek nth from top (1 = top)',
  'vm.env_read(-idx)     # Read local variable at idx',
  'vm.env_write(-idx, v) # Write local variable at idx',
  'vm.add_pc(offset)     # Adjust PC by offset (for branches)',
  'vm.define_method(m, iseq)  # Register method on class',
  'vm.sendish(cd)        # Dispatch method call',
]

function App() {
  const { vmRef, status, error } = useRubyVM()
  const { state, goToStep, updateCode, runTests } = useChallenge({ vmRef })
  const currentStep = STEPS.find(s => s.id === state.currentStep)

  const runButtonRef = useRef<HTMLButtonElement>(null)

  // Keyboard shortcut: Ctrl+Enter / Cmd+Enter to run tests
  useEffect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault()
        runButtonRef.current?.click()
      }
    }
    window.addEventListener('keydown', handleKeydown)
    return () => window.removeEventListener('keydown', handleKeydown)
  }, [])

  if (status === 'loading') {
    return (
      <div className="loading-screen">
        <h1>Ruby YARV Challenge</h1>
        <div className="spinner" />
        <p className="loading-msg">Loading ruby.wasm…</p>
        <div className="loading-api">
          <p className="loading-api-title">VM API you'll use:</p>
          <pre className="loading-api-code">{VM_API_LINES.join('\n')}</pre>
        </div>
      </div>
    )
  }

  if (status === 'error') {
    return (
      <div className="error-screen">
        <h1>⚠️ Error Loading Ruby VM</h1>
        <p>{error}</p>
        <p>Please refresh the page and try again.</p>
      </div>
    )
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>Ruby YARV Challenge</h1>
        <p>Implement a Ruby VM &amp; compiler — step by step</p>
      </header>

      <StepNav
        currentStep={state.currentStep}
        completedSteps={state.completedSteps}
        onStepChange={goToStep}
      />

      {currentStep && (
        <Layout
          left={<TutorialPane step={currentStep} result={state.lastResult} />}
          center={
            <EditorPane
              code={state.userCode[state.currentStep] ?? currentStep.stub}
              onChange={updateCode}
              onReset={() => updateCode(currentStep.stub)}
              isRunning={state.isRunning}
            />
          }
          right={
            <ResultPane
              result={state.lastResult}
              expectedBytecode={currentStep.bytecodePreview}
              onNextStep={() => goToStep(state.currentStep + 1)}
              isLastStep={state.currentStep === STEPS[STEPS.length - 1].id}
            />
          }
        />
      )}

      <footer className="app-footer">
        <button
          ref={runButtonRef}
          className="run-button"
          onClick={runTests}
          disabled={state.isRunning}
        >
          {state.isRunning ? '⏳ Running...' : '▶ Run Tests'}
        </button>
        <span className="shortcut-hint">Ctrl+Enter / Cmd+Enter</span>
      </footer>
    </div>
  )
}

export default App
