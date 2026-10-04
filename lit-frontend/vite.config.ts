import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [tailwindcss()],
  // Surfaced in the UI so it is immediately obvious whether a browser is
  // running the current build or a cached older one.
  define: {
    __BUILD_TIME__: JSON.stringify(new Date().toISOString().slice(0, 16).replace('T', ' ')),
  },
  build: {
    target: 'esnext',
    minify: 'esbuild',
  },
  server: {
    port: 3000,
    open: true,
  },
});
