"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";

/**
 * Global interceptor để xử lý response 401 Unauthorized
 * Tự động logout user khi token hết hạn hoặc không hợp lệ
 */
export function GlobalAuthInterceptor() {
  const router = useRouter();

  useEffect(() => {
    // Override fetch để intercept tất cả các request
    const originalFetch = window.fetch;
    
    window.fetch = async (...args) => {
      const response = await originalFetch(...args);
      
      // Kiểm tra nếu response là 401 Unauthorized
      if (response.status === 401) {
        let url = '';
        if (typeof args[0] === 'string') {
          url = args[0];
        } else if (args[0] instanceof Request) {
          url = args[0].url;
        } else if (args[0] instanceof URL) {
          url = args[0].toString();
        }
        
        // Bỏ qua login endpoint để tránh vòng lặp
        if (!url.includes('/auth/login') && !url.includes('/login')) {
          // Clear auth data và redirect
          authService.clearAllAuthData();
          router.push('/login');
        }
      }
      
      return response;
    };

    // Cleanup function để restore original fetch
    return () => {
      window.fetch = originalFetch;
    };
  }, [router]);

  // Component không render gì
  return null;
}
