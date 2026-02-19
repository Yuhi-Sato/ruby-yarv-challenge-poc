import { STEPS } from '../steps'
import './StepNav.css'

interface StepNavProps {
  currentStep: number
  onStepChange: (stepId: number) => void
}

export function StepNav({ currentStep, onStepChange }: StepNavProps) {
  return (
    <nav className="step-nav">
      <div className="step-group">
        <div className="step-buttons">
          {STEPS.map(step => (
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

      <div className="current-step">
        <p>
          <strong>Current:</strong> {STEPS.find(s => s.id === currentStep)?.title}
        </p>
      </div>
    </nav>
  )
}
