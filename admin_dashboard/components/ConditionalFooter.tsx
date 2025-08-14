"use client";

import { usePathname } from "next/navigation";
import Footer from "./footer";

export default function ConditionalFooter() {
  const pathname = usePathname();
  
  // Don't show footer on login page (handle both /login and /login/)
  if (pathname === "/login" || pathname === "/login/") {
    return null;
  }
  
  return <Footer />;
}
