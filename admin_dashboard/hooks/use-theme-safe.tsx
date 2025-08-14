"use client";

import { useTheme } from "next-themes";
import { useEffect, useState } from "react";

export function useThemeSafe() {
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  // Only render after client mount to avoid hydration issues
  useEffect(() => {
    setMounted(true);
  }, []);

  return {
    theme: mounted ? theme : "light", // fallback to light theme during SSR
    setTheme,
    mounted,
  };
}
