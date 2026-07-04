import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig(({ mode }) => ({
  plugins: [tailwindcss(), sveltekit()],
  build: {
    minify: mode !== 'development',
    cssMinify: mode !== 'development',
    rolldownOptions: {
      checks: { pluginTimings: false },
    },
  },
  server: {
    host: '0.0.0.0',
    proxy: {
      '/api': 'http://127.0.0.1:4433',
      '/static': 'http://127.0.0.1:4433',
      '/search': 'http://127.0.0.1:4433',
    },
  },
}));
