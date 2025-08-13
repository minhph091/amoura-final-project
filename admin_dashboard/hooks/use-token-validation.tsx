"use client";

import { useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";
import { apiClient } from "@/src/services/api.service";

export function useTokenValidation() {
  const router = useRouter();
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const isCheckingRef = useRef(false);

  const checkTokenValidity = async () => {
    if (isCheckingRef.current) return;
    
    const token = localStorage.getItem("auth_token");
    if (!token) {
      await handleLogout();
      return;
    }

    isCheckingRef.current = true;

    try {
      // Gọi API để kiểm tra token có còn hợp lệ không
      const response = await apiClient.get("/profile/me");
      
      if (!response.success) {
        // Token không hợp lệ hoặc hết hạn
        if (response.error?.includes("Authentication required") || 
            response.error?.includes("Invalid") ||
            response.error?.includes("401") ||
            response.error?.includes("Unauthorized")) {
          await handleLogout();
        }
      }
    } catch (error) {
      // Chỉ logout nếu error liên quan đến authentication
      const errorMessage = error instanceof Error ? error.message : String(error);
      if (errorMessage.includes("401") || 
          errorMessage.includes("Unauthorized") || 
          errorMessage.includes("Authentication")) {
        await handleLogout();
      }
    } finally {
      isCheckingRef.current = false;
    }
  };

  const handleLogout = async () => {
    try {
      await authService.logout();
      router.push("/login");
    } catch (error) {
      // Force logout anyway
      authService.clearAllAuthData();
      router.push("/login");
    }
  };

  useEffect(() => {
    // Chỉ chạy validation khi có token và đã login
    const isLoggedIn = localStorage.getItem("isLoggedIn") === "true";
    const token = localStorage.getItem("auth_token");
    
    if (!isLoggedIn || !token) {
      return;
    }

    // Kiểm tra token ngay lập tức
    checkTokenValidity();

    // Thiết lập interval để kiểm tra token định kỳ (mỗi 5 phút)
    intervalRef.current = setInterval(checkTokenValidity, 5 * 60 * 1000);

    // Listen cho storage events để sync logout giữa các tabs
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'auth_token' && e.newValue === null) {
        // Token đã bị xóa từ tab khác
        handleLogout();
      }
    };

    window.addEventListener('storage', handleStorageChange);

    // Cleanup function
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  // Cleanup khi component unmount
  useEffect(() => {
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    };
  }, []);

  return { checkTokenValidity, handleLogout };
}
