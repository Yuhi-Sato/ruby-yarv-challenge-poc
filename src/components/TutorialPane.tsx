import { useState } from 'react'
import type { StepConfig, RunResult } from '../types'
import './TutorialPane.css'

interface TutorialPaneProps {
  step: StepConfig
  result: RunResult | null
}

const VM_API = [
  { sig: 'vm.push(x)', desc: 'Push value onto stack' },
  { sig: 'vm.pop', desc: 'Pop and return top value' },
  { sig: 'vm.topn(n)', desc: 'Peek nth from top (1 = top)' },
  { sig: 'vm.env_read(index)', desc: 'Read local variable at index' },
  { sig: 'vm.env_write(index, v)', desc: 'Write local variable at index' },
  { sig: 'vm.add_pc(offset)', desc: 'Adjust PC by relative offset (branches)' },
  { sig: 'vm.define_method(m, i)', desc: 'Register method iseq on current class' },
  { sig: 'vm.sendish(cd)', desc: 'Dispatch method call → returns result' },
  { sig: 'vm.self_value', desc: 'Current self object' },
]

export function TutorialPane({ step, result }: TutorialPaneProps) {
  const [showBytecode, setShowBytecode] = useState(false)
  const [showApi, setShowApi] = useState(false)

  return (
    <div className="tutorial-pane">
      <div className="section description-section">
        {step.description}
      </div>

      <div className="section">
        <h3>Test Cases</h3>
        <div className="test-cases-preview">
          {step.testCases.map((tc, i) => (
            <div key={i} className="test-case-row">
              <code className="test-source">{tc.source}</code>
              <span className="test-arrow">→</span>
              <code className="test-expected">{String(tc.expected)}</code>
            </div>
          ))}
        </div>
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

      <div className="section">
        <button
          className="toggle-btn api-toggle"
          onClick={() => setShowApi(!showApi)}
        >
          {showApi ? '▼' : '▶'} VM API Reference
        </button>
        {showApi && (
          <table className="api-table">
            <tbody>
              {VM_API.map(({ sig, desc }) => (
                <tr key={sig}>
                  <td><code>{sig}</code></td>
                  <td>{desc}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

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
