import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: ["duke-pauper-overbid.ngrok-free.dev"],
    proxy: {
      '/api': {
        target: 'https://fascism-bullseye-perjury.ngrok-free.dev',
        changeOrigin: true,
        secure: false,
        headers: {
          'ngrok-skip-browser-warning': 'true'
        }
      },
      '/storage': {
        target: 'https://fascism-bullseye-perjury.ngrok-free.dev',
        changeOrigin: true,
        secure: false,
        headers: {
          'ngrok-skip-browser-warning': 'true'
        }
      }
    }
  }
})
