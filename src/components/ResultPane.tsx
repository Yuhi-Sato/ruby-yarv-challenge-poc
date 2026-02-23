import type { RunResult } from '../types'
import './ResultPane.css'

interface ResultPaneProps {
  result: RunResult | null
  expectedBytecode?: string
  onNextStep?: () => void
  isLastStep?: boolean
}

function prettifyError(msg: string): string {
  // Detect NotImplementedError — tell user what to implement
  const niMatch = msg.match(/(\w+(?:\.\w+)?)\s+not implemented/)
  if (niMatch) {
    return `${niMatch[1]} is not implemented yet.\nImplement it in the editor, then click Run Tests.`
  }
  // Strip internal eval stack frames to reduce noise
  return msg
    .split('\n')
    .filter(l => !l.match(/^\s+eval:\d+:in/))
    .join('\n')
    .trim()
}

export function ResultPane({ result, expectedBytecode, onNextStep, isLastStep }: ResultPaneProps) {
  return (
    <div className="result-pane">
      {/* Expected bytecode — always shown if available */}
      {expectedBytecode && (
        <div className="section">
          <h3>Expected Bytecode</h3>
          <pre className="bytecode-display expected">{expectedBytecode}</pre>
        </div>
      )}

      {!result && (
        <div className="empty-state">
          <p>Implement the code in the editor</p>
          <p>then click <strong>Run Tests</strong></p>
        </div>
      )}

      {result && (
        <>
          <div className="result-header">
            <div className={`status-badge ${result.allPassed ? 'passed' : 'failed'}`}>
              {result.allPassed ? '✅ ALL PASSED' : '❌ SOME FAILED'}
            </div>
          </div>

          {/* Actual bytecode — only shown after all tests pass */}
          {result.allPassed && result.bytecodeDisasm && (
            <div className="section">
              <h3>Your Bytecode</h3>
              <pre className="bytecode-display actual">{result.bytecodeDisasm}</pre>
            </div>
          )}

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
              <pre className="error-message">{prettifyError(result.errorMessage)}</pre>
            </div>
          )}

          {result.allPassed && !isLastStep && onNextStep && (
            <div className="section">
              <button className="next-step-btn" onClick={onNextStep}>
                Next Step →
              </button>
            </div>
          )}

          {result.allPassed && isLastStep && (
            <div className="section celebration">
              <p>🎉 <strong>Congratulations!</strong></p>
              <p>You implemented a Ruby VM and compiler from scratch!</p>
              <p><code>fib(10) = 55</code> ✨</p>
            </div>
          )}
        </>
      )}
    </div>
  )
}
