/** @type {import('next').NextConfig} */

const isProduction = process.env.NODE_ENV === 'production';
const isDevelopment = process.env.NODE_ENV === 'development';

const nextConfig = {
  // Only use export mode for production builds that need static files
  ...(isProduction && process.env.NEXT_EXPORT === 'true' && {
    output: 'export',
    trailingSlash: true,
  }),
  
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
    domains: ['api.amoura.space', 'amoura.space'],
  },
  experimental: {
    webpackBuildWorker: false,
  },
  webpack: (config) => {
    config.cache = false;
    return config;
  },
  
  // Only use rewrites and headers when NOT in export mode
  ...(!isProduction || process.env.NEXT_EXPORT !== 'true') && {
    async rewrites() {
      if (isDevelopment) {
        return [
          {
            source: '/api/:path*',
            destination: 'http://localhost:8080/api/:path*',
          },
          // WebSocket proxy
          {
            source: '/api/ws',
            destination: 'http://localhost:8080/ws',
          },
        ];
      }
      return [];
    },
    async headers() {
      return [
        {
          // matching all API routes
          source: "/api/:path*",
          headers: [
            { key: "Access-Control-Allow-Credentials", value: "true" },
            { key: "Access-Control-Allow-Origin", value: "*" },
            { key: "Access-Control-Allow-Methods", value: "GET,OPTIONS,PATCH,DELETE,POST,PUT" },
            { key: "Access-Control-Allow-Headers", value: "X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization" },
          ]
        }
      ]
    },
  }
};

export default nextConfig;
