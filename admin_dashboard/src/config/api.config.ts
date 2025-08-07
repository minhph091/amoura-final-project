// Environment configuration for API URLs
declare const process: any;

export const API_CONFIG = {
  BASE_URL:
    process?.env?.NEXT_PUBLIC_API_URL ||
    (typeof window !== "undefined" && window.location.hostname === "localhost"
      ? "/api" // Use proxy to avoid CORS issues in development
      : "https://api.amoura.space/api"),
  // WebSocket URL - use proxy endpoint in development
  WS_URL: 
    process?.env?.NEXT_PUBLIC_WS_URL || 
    (typeof window !== "undefined" && window.location.hostname === "localhost"
      ? "ws://localhost:3000/api/ws"
      : "wss://api.amoura.space/ws"),
} as const;
