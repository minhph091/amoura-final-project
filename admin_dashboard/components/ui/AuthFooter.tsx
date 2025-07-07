import React from "react";
import Link from "next/link";
import { AmouraLogo } from "./AmouraLogo";

export function AuthFooter() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="w-full py-6 px-4 border-t bg-background/80 backdrop-blur-sm">
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row items-center justify-between space-y-4 md:space-y-0">
          <div className="flex items-center space-x-6">
            <AmouraLogo size="small" />
            <div className="text-sm text-muted-foreground">Admin Dashboard</div>
          </div>

          <div className="flex items-center space-x-6 text-sm text-muted-foreground">
            <Link
              href="/support"
              className="hover:text-foreground transition-colors"
            >
              Support
            </Link>
          </div>

          <div className="text-sm text-muted-foreground">
            © {currentYear} Amoura. All rights reserved.
          </div>
        </div>
      </div>
    </footer>
  );
}
