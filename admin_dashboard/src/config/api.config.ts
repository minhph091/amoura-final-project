// Environment configuration for API URLs
declare const process: any;

export const API_CONFIG = {
  BASE_URL:
    process?.env?.NEXT_PUBLIC_API_URL ||
    (typeof window !== "undefined" && window.location.hostname === "localhost"
      ? "http://localhost:8080/api"
      : "https://api.amoura.space/api"),
  WS_URL: process?.env?.NEXT_PUBLIC_WS_URL || "wss://api.amoura.space/api/ws",
} as const;
