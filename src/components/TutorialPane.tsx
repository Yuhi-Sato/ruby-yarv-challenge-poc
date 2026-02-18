import { useState } from 'react'
import type { StepConfig, RunResult } from '../types'
import './TutorialPane.css'

interface TutorialPaneProps {
  step: StepConfig
  result: RunResult | null
}

export function TutorialPane({ step, result }: TutorialPaneProps) {
  const [showBytecode, setShowBytecode] = useState(false)

  return (
    <div className="tutorial-pane">
      <div className="section">
        <h2>{step.title}</h2>
        <div className="description">
          {step.description.split('\n').map((line, i) => (
            <div key={i}>{line}</div>
          ))}
        </div>
      </div>

      <div className="section">
        <h3>Instructions</h3>
        <p className="instructions-text">{step.instructions}</p>
      </div>

      <div className="section">
        <h3>Test Code</h3>
        <pre className="code-block">{step.testCases[0]?.source || 'No test'}</pre>
      </div>

      {step.bytecodePreview && (
        <div className="section">
          <button
            className="toggle-btn"
            onClick={() => setShowBytecode(!showBytecode)}
          >
            {showBytecode ? '▼' : '▶'} Expected Bytecode
          </button>
          {showBytecode && (
            <pre className="code-block">{step.bytecodePreview}</pre>
          )}
        </div>
      )}

      {result && result.allPassed && (
        <div className="section success-box">
          <p>✅ <strong>All tests passed!</strong></p>
        </div>
      )}

      {result && !result.allPassed && (
        <div className="section error-box">
          <p>❌ Some tests failed</p>
        </div>
      )}
    </div>
  )
}
