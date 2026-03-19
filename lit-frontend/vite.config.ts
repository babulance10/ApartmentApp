import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    target: 'esnext',
    minify: 'esbuild',
  },
  server: {
    port: 3000,
    open: true,
  },
});
