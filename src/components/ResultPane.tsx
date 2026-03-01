import type { RunResult } from '../types'
import './ResultPane.css'

interface ResultPaneProps {
  result: RunResult | null
  expectedBytecode?: string
  onNextStep?: () => void
  isLastStep?: boolean
}

function prettifyError(msg: string): string {
  // Detect NotImplementedError — tell user exactly which method to implement
  const niMatch = msg.match(/(\w+(?:[.#]\w+)?)\s+not implemented/)
  if (niMatch || msg.includes('NotImplementedError')) {
    const name = niMatch ? niMatch[1] : null
    if (name) {
      return `🔧 ${name} is not yet implemented.\n\nWrite your implementation in the editor and click Run Tests.`
    }
    return `🔧 A required method is not yet implemented.\n\nWrite your implementation in the editor and click Run Tests.`
  }

  // Detect SyntaxError — show only the relevant line
  const syntaxMatch = msg.match(/SyntaxError[^:]*:\s*(.+?)(?:\n|$)/)
  if (syntaxMatch) {
    return `Syntax error: ${syntaxMatch[1]}`
  }

  // For all other errors: strip internal eval stack frames and cap at 8 lines
  const cleaned = msg
    .split('\n')
    .filter(l => !l.match(/^\s+(from\s+)?\(eval\):\d+/) && !l.match(/^\s+eval:\d+:in/))
    .slice(0, 8)
    .join('\n')
    .trim()

  // Highlight the core error message (first non-empty line)
  return cleaned
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
                    {!test.passed && test.error && (
                      <div className="test-error">
                        <pre className="test-error-message">{prettifyError(test.error)}</pre>
                      </div>
                    )}
                    {!test.passed && !test.error && (
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
