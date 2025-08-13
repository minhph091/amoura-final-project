"use client";

import { useEffect, useState } from "react";

export function useSafeDate() {
  const [mounted, setMounted] = useState(false);
  const [currentDate, setCurrentDate] = useState("");

  useEffect(() => {
    setMounted(true);
    // Use consistent date format
    const today = new Date();
    const formattedDate = `${
      today.getMonth() + 1
    }/${today.getDate()}/${today.getFullYear()}`;
    setCurrentDate(formattedDate);
  }, []);

  return {
    mounted,
    currentDate: mounted ? currentDate : "7/12/2025", // consistent fallback for SSR
    currentYear: new Date().getFullYear(),
  };
}
