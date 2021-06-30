import { defineConfig } from "vite";
import reactRefresh from "@vitejs/plugin-react-refresh";
import path from "path";
console.log(path.resolve("common/src/index.tsx"));

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [reactRefresh()],
  resolve: {
    alias: {
      "linear-common": path.resolve("../common/src"),
    },
  },
});
