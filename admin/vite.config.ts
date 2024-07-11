import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: "/admin",
  server: {
    proxy: {
      "/api": "http://localhost:3000",
      "/static/media": "http://localhost:3000",
    },
  },
});
