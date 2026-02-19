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
        <p>Loading ruby.wasm...</p>
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
        <h1>🦀 Ruby YARV Challenge</h1>
        <p>Learn Ruby VM & Compiler Implementation</p>
      </header>

      <StepNav currentStep={state.currentStep} onStepChange={goToStep} />

      {currentStep && (
        <Layout
          left={<TutorialPane step={currentStep} result={state.lastResult} />}
          center={
            <EditorPane
              code={state.userCode[state.currentStep] ?? currentStep.stub}
              onChange={updateCode}
              isRunning={state.isRunning}
            />
          }
          right={<ResultPane result={state.lastResult} />}
        />
      )}

      <footer className="app-footer">
        <button
          ref={runButtonRef}
          className="run-button"
          onClick={runTests}
          disabled={state.isRunning}
        >
          {state.isRunning ? '⏳ Running...' : '▶️ Run Tests'}
        </button>
        <span className="shortcut-hint">Ctrl+Enter / Cmd+Enter</span>
      </footer>
    </div>
  )
}

export default App
