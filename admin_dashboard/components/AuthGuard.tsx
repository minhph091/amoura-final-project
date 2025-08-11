"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useTokenValidation } from "@/hooks/use-token-validation";

interface AuthGuardProps {
  children: React.ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const router = useRouter();
  const { handleLogout } = useTokenValidation();

  useEffect(() => {
    // Listen for token expired events
    const handleTokenExpired = () => {
      handleLogout();
    };

    window.addEventListener('token-expired', handleTokenExpired);

    return () => {
      window.removeEventListener('token-expired', handleTokenExpired);
    };
  }, [handleLogout]);

  return <>{children}</>;
}
