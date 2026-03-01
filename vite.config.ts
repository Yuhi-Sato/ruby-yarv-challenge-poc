import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import wasm from 'vite-plugin-wasm'
import topLevelAwait from 'vite-plugin-top-level-await'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    wasm(),
    topLevelAwait(),
  ],
  optimizeDeps: {
    exclude: ['@ruby/4.0-wasm-wasi', '@ruby/wasm-wasi'],
  },
  base: '/ruby-yarv-challenge-poc/',
})
