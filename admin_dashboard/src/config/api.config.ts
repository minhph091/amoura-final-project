// Environment configuration for API URLs
declare const process: any;

// Function to get environment variable with fallback
const getEnvVar = (key: string, defaultValue: string): string => {
  // Check if we're in browser environment
  if (typeof window !== 'undefined') {
    // In browser, environment variables are embedded at build time
    return process.env[key] || defaultValue;
  }
  // In server-side rendering
  return process.env[key] || defaultValue;
};

export const API_CONFIG = {
  BASE_URL: getEnvVar('NEXT_PUBLIC_API_URL', 'https://api.amoura.space/api'),
  WS_URL: getEnvVar('NEXT_PUBLIC_WS_URL', 'wss://api.amoura.space/ws'),
} as const;

// Debug log to check what URL is being used
if (typeof window !== 'undefined') {
  console.log('🔗 API Config:', {
    BASE_URL: API_CONFIG.BASE_URL,
    WS_URL: API_CONFIG.WS_URL,
    NODE_ENV: process.env.NODE_ENV,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL,
    NEXT_PUBLIC_WS_URL: process.env.NEXT_PUBLIC_WS_URL
  });
}
