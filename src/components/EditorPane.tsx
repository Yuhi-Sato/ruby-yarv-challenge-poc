import { useState } from 'react'
import Editor from '@monaco-editor/react'
import type { StepConfig } from '../types'
import './EditorPane.css'

interface EditorPaneProps {
  step: StepConfig
  onChange: (code: string) => void
  isRunning: boolean
}

export function EditorPane({ step, onChange, isRunning }: EditorPaneProps) {
  const [activeTab, setActiveTab] = useState<'vm' | 'compiler'>('vm')

  const isCompilerPhase = step.phase === 'Compiler'
  const displayCode = activeTab === 'vm' ? step.vmStub : step.compilerStub

  return (
    <div className="editor-pane">
      <div className="editor-tabs">
        <button
          className={`tab ${activeTab === 'vm' ? 'active' : ''}`}
          onClick={() => setActiveTab('vm')}
          disabled={isRunning}
        >
          VM
        </button>
        <button
          className={`tab ${activeTab === 'compiler' ? 'active' : ''} ${!isCompilerPhase ? 'disabled' : ''}`}
          onClick={() => isCompilerPhase && setActiveTab('compiler')}
          disabled={!isCompilerPhase || isRunning}
          title={!isCompilerPhase ? 'Compiler phase only' : ''}
        >
          Compiler
        </button>
      </div>

      <div className="editor-container">
        <Editor
          height="100%"
          language="ruby"
          value={displayCode}
          onChange={(value) => onChange(value || '')}
          theme="light"
          options={{
            minimap: { enabled: false },
            fontSize: 13,
            wordWrap: 'on',
            lineNumbers: 'on',
            readOnly: false,
            automaticLayout: true,
            tabSize: 2,
            insertSpaces: true,
          }}
        />
      </div>

      {isRunning && (
        <div className="running-indicator">
          <span className="spinner" />
          Running tests...
        </div>
      )}
    </div>
  )
}
