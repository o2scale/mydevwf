import { defineConfig } from 'vitest/config';
import path from 'path';

/**
 * Vitest Configuration for MyDevWF Projects
 *
 * This configuration is designed for the hybrid Vitest + Playwright MCP testing workflow.
 * Unit tests are located in docs/qa/unit/ following the sprint/epic/story hierarchy.
 *
 * Usage:
 * - Copy this file to your project root as `vitest.config.ts`
 * - Adjust the alias paths to match your project structure
 * - Run tests with: npm run test
 */

export default defineConfig({
  test: {
    // Include unit tests from docs/qa/unit/ directory
    include: [
      'docs/qa/unit/**/*.test.ts',
      'docs/qa/unit/**/*.test.tsx',
      'docs/qa/unit/**/*.spec.ts',
      'docs/qa/unit/**/*.spec.tsx'
    ],

    // Exclude common non-test directories
    exclude: [
      'node_modules',
      'dist',
      '.idea',
      '.git',
      '.cache',
      'build',
      'coverage'
    ],

    // Enable globals (describe, it, expect available without import)
    globals: true,

    // Test environment
    // Use 'node' for backend/API tests
    // Use 'jsdom' or 'happy-dom' for frontend tests
    environment: 'node',

    // Coverage configuration (optional)
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.config.{js,ts}',
        '**/*.d.ts',
        'docs/',
        '.next/',
        'build/'
      ]
    },

    // Timeout for tests (milliseconds)
    testTimeout: 10000,

    // Hooks timeout
    hookTimeout: 10000,

    // Silent console output (set to false for debugging)
    silent: false,

    // Number of threads (0 = auto)
    threads: true,

    // Fail fast on first test failure
    // bail: 1,
  },

  resolve: {
    alias: {
      // Adjust these aliases to match your project structure
      '@': path.resolve(__dirname, './src'),
      '@/lib': path.resolve(__dirname, './src/lib'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/utils': path.resolve(__dirname, './src/utils'),
    },
  },
});
