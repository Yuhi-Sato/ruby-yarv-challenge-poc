import type { ReactNode } from 'react'
import './Layout.css'

interface LayoutProps {
  left: ReactNode
  center: ReactNode
  right: ReactNode
}

/**
 * 3-pane layout: 30% tutorial | 40% editor | 30% results
 */
export function Layout({ left, center, right }: LayoutProps) {
  return (
    <div className="layout">
      <div className="pane pane-left">
        {left}
      </div>
      <div className="pane pane-center">
        {center}
      </div>
      <div className="pane pane-right">
        {right}
      </div>
    </div>
  )
}
