import { useEffect, useRef, useState } from 'react'
// @ts-ignore
import { DefaultRubyVM } from '@ruby/wasm-wasi/dist/browser'
// @ts-ignore
import rubyWasm from '@ruby/4.0-wasm-wasi/dist/ruby+stdlib.wasm?url'

export type VMStatus = 'loading' | 'ready' | 'error'
export type VMInstance = any // ruby.wasm types are not well typed

export function useRubyVM() {
  const vmRef = useRef<VMInstance | null>(null)
  const [status, setStatus] = useState<VMStatus>('loading')
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false

    async function init() {
      try {
        const response = await fetch(rubyWasm)
        const buffer = await response.arrayBuffer()
        const module = await WebAssembly.compile(buffer)

        const { vm } = await DefaultRubyVM(module, { consolePrint: false })

        if (!vm) {
          throw new Error('Ruby VM not available')
        }

        if (cancelled) return

        // Prism is built into Ruby 4.0 — require it upfront
        vm.eval(`require 'prism'`)

        vmRef.current = vm
        setStatus('ready')
      } catch (e) {
        if (!cancelled) {
          setError(String(e))
          setStatus('error')
        }
      }
    }

    init()
    return () => { cancelled = true }
  }, [])

  return { vmRef, status, error }
}
