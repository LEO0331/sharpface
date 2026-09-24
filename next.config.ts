import type { NextConfig } from "next";

// Static export for GitHub Pages. The deploy workflow sets PAGES_BASE_PATH to "/<repo>".
const basePath = process.env.PAGES_BASE_PATH || "";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  trailingSlash: true,
  images: { unoptimized: true },
};
export default nextConfig;
