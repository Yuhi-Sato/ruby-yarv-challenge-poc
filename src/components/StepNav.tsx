import { STEPS } from '../steps'
import './StepNav.css'

interface StepNavProps {
  currentStep: number
  onStepChange: (stepId: number) => void
}

export function StepNav({ currentStep, onStepChange }: StepNavProps) {
  const vmSteps = STEPS.filter(s => s.phase === 'VM')
  const compilerSteps = STEPS.filter(s => s.phase === 'Compiler')

  return (
    <nav className="step-nav">
      <div className="step-group">
        <h3>Phase A: VM Instructions</h3>
        <div className="step-buttons">
          {vmSteps.map(step => (
            <button
              key={step.id}
              className={`step-btn ${currentStep === step.id ? 'active' : ''}`}
              onClick={() => onStepChange(step.id)}
              title={step.title}
            >
              {step.id}
            </button>
          ))}
        </div>
      </div>

      <div className="step-divider" />

      <div className="step-group">
        <h3>Phase B: Compiler</h3>
        <div className="step-buttons">
          {compilerSteps.map(step => (
            <button
              key={step.id}
              className={`step-btn ${currentStep === step.id ? 'active' : ''}`}
              onClick={() => onStepChange(step.id)}
              title={step.title}
            >
              B{step.id - 100}
            </button>
          ))}
        </div>
      </div>

      <div className="current-step">
        <p>
          <strong>Current:</strong> {STEPS.find(s => s.id === currentStep)?.title}
        </p>
      </div>
    </nav>
  )
}
