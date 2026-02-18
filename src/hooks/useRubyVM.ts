import { useEffect, useRef, useState } from 'react'
// @ts-ignore
import { DefaultRubyVM } from '@ruby/wasm-wasi/dist/browser'
// @ts-ignore
import rubyWasm from '@ruby/3.4-wasm-wasi/dist/ruby.wasm?url'

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
        // Fetch the Ruby WASM binary
        const response = await fetch(rubyWasm)
        const buffer = await response.arrayBuffer()
        const module = await WebAssembly.compile(buffer)

        // Initialize the default Ruby WASM VM with the compiled module
        const { vm } = await DefaultRubyVM(module, { consolePrint: false })

        if (!vm) {
          throw new Error('Ruby VM not available')
        }

        if (cancelled) return

        // Try to pre-load Prism, but don't fail if it's not available
        // The system Ruby code will handle parsing without it if needed
        try {
          vm.eval(`require 'prism'`)
        } catch (_e) {
          // Prism might not be available in this ruby.wasm build
          // We'll work around this by using the parser from our system code
          console.warn('Prism gem not available in ruby.wasm, will use builtin parser')
        }

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
