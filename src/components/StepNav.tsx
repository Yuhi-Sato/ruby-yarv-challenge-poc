import { STEPS } from '../steps'
import './StepNav.css'

interface StepNavProps {
  currentStep: number
  completedSteps: number[]
  onStepChange: (stepId: number) => void
}

export function StepNav({ currentStep, completedSteps, onStepChange }: StepNavProps) {
  return (
    <nav className="step-nav">
      <div className="step-group">
        <div className="step-buttons">
          {STEPS.map(step => {
            const isCompleted = completedSteps.includes(step.id)
            const isActive = currentStep === step.id
            return (
              <button
                key={step.id}
                className={`step-btn ${isActive ? 'active' : ''} ${isCompleted && !isActive ? 'completed' : ''}`}
                onClick={() => onStepChange(step.id)}
                title={step.title}
              >
                {isCompleted && !isActive ? '✓' : step.id}
              </button>
            )
          })}
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
