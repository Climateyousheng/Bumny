import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  test: {
    globals: true,
    environment: "jsdom",
    environmentOptions: {
      jsdom: {
        url: "http://localhost",
      },
    },
    setupFiles: ["./tests/setup.ts"],
    pool: "forks",
    poolOptions: {
      forks: {
        maxForks: 4,
      },
    },
    exclude: ["e2e/**", "node_modules/**"],
    css: false,
    coverage: {
      provider: "v8",
      include: ["src/**/*.{ts,tsx}"],
      exclude: [
        "src/main.tsx",
        "src/components/ui/**",
        "src/**/*.d.ts",
      ],
    },
  },
});
