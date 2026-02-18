import { useState } from 'react'
import type { RunResult } from '../types'
import './ResultPane.css'

interface ResultPaneProps {
  result: RunResult | null
}

export function ResultPane({ result }: ResultPaneProps) {
  const [showBytecode, setShowBytecode] = useState(false)

  if (!result) {
    return (
      <div className="result-pane">
        <div className="empty-state">
          <p>👈 Select a step and implement the code</p>
          <p>Then click "Run Tests" to see results here</p>
        </div>
      </div>
    )
  }

  return (
    <div className="result-pane">
      <div className="result-header">
        <div className={`status-badge ${result.allPassed ? 'passed' : 'failed'}`}>
          {result.allPassed ? '✅ ALL PASSED' : '❌ SOME FAILED'}
        </div>
      </div>

      <div className="section">
        <button
          className="toggle-btn"
          onClick={() => setShowBytecode(!showBytecode)}
        >
          {showBytecode ? '▼' : '▶'} Bytecode
        </button>
        {showBytecode && (
          <pre className="bytecode-display">{result.bytecodeDisasm}</pre>
        )}
      </div>

      <div className="section">
        <h3>Test Results</h3>
        <div className="test-results">
          {result.testResults.map((test, i) => (
            <div key={i} className={`test-item ${test.passed ? 'passed' : 'failed'}`}>
              <div className="test-status">
                {test.passed ? '✓' : '✗'}
              </div>
              <div className="test-details">
                <div className="test-description">{test.description}</div>
                {!test.passed && (
                  <div className="test-values">
                    <div>Expected: <code>{test.expected}</code></div>
                    <div>Got: <code>{test.got}</code></div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {result.errorMessage && (
        <div className="section error-section">
          <h3>Error</h3>
          <pre className="error-message">{result.errorMessage}</pre>
        </div>
      )}
    </div>
  )
}
