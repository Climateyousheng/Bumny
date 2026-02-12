import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    proxy: {
      "/experiments": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
      "/bridge": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
      "/process": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
      "/submit": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
    },
  },
});
