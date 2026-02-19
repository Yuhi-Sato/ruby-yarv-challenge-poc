import Editor from '@monaco-editor/react'
import './EditorPane.css'

interface EditorPaneProps {
  code: string
  onChange: (code: string) => void
  isRunning: boolean
}

export function EditorPane({ code, onChange, isRunning }: EditorPaneProps) {
  return (
    <div className="editor-pane">
      <div className="editor-container">
        <Editor
          height="100%"
          language="ruby"
          value={code}
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
