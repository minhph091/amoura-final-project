"use client";

import { usePathname } from "next/navigation";
import Footer from "./footer";

export default function ConditionalFooter() {
  const pathname = usePathname();
  
  // Debug: log pathname to see what we're getting
  console.log("ConditionalFooter pathname:", pathname);
  
  // Don't show footer on login page (handle both /login and /login/)
  if (pathname === "/login" || pathname === "/login/") {
    console.log("Hiding footer for login page");
    return null;
  }
  
  console.log("Showing footer");
  return <Footer />;
}
