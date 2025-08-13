
"use client";
import Link from "next/link";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { authService } from "@/src/services/auth.service";
import { useEffect, useState } from "react";
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function Footer() {
  const { t } = useLanguage();
  const [role, setRole] = useState<string | null>(null);
  
  // Basic defensive check for footer translations
  if (!t || !t.footer || typeof t.footer !== 'object') {
    // Return simple fallback footer instead of null
    return (
      <footer className="w-full bg-white/80 border-t border-gray-200 py-8 px-4 mt-12">
        <div className="max-w-7xl mx-auto text-center">
          <p className="text-sm text-gray-600">Amoura Admin Dashboard</p>
        </div>
      </footer>
    );
  }
  
  useEffect(() => {
    if (typeof window !== "undefined") {
      const user = authService.getCurrentUser();
      setRole(user?.roleName || null);
    }
  }, []);

  const isAdmin = role === "ADMIN";
  const isModerator = role === "MODERATOR";

  return (
    <footer className="w-full bg-white/80 border-t border-gray-200 py-8 px-4 mt-12">
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-8 items-start">
        <div className="space-y-3">
          <AmouraLogo size="default" />
          <p className="text-sm text-gray-600 max-w-xs">
            {t.footer.title || "Amoura Admin"} - {t.footer.description || "Admin Dashboard"}
          </p>
          <p className="text-xs text-gray-400">
            {t.footer.madeWith || "Made with"} <span className="text-pink-500">♥</span> {t.footer.forAdministrators || "for administrators"}
          </p>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">{t.footer.quickLinks || "Quick Links"}</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/dashboard" className="hover:text-pink-600">{t.dashboard || "Dashboard"}</Link>
            </li>
            <li>
              <Link href="/dashboard/users" className="hover:text-pink-600">{t.users || "Users"}</Link>
            </li>
            {isAdmin && (
              <>
                <li>
                  <Link href="/dashboard/moderators" className="hover:text-pink-600">{t.moderators || "Moderators"}</Link>
                </li>
                <li>
                  <Link href="/add-account" className="hover:text-pink-600">{t.addAccount || "Add Account"}</Link>
                </li>
              </>
            )}
            <li>
              <Link href="/dashboard/settings" className="hover:text-pink-600">{t.header?.settings || "Settings"}</Link>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">{t.footer.support || "Support"}</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/help" className="hover:text-pink-600">{t.footer.helpCenter || "Help Center"}</Link>
            </li>
            <li>
              <Link href="/privacy" className="hover:text-pink-600">{t.footer.privacy || "Privacy Policy"}</Link>
            </li>
            <li>
              <Link href="/terms" className="hover:text-pink-600">{t.footer.terms || "Terms of Service"}</Link>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">{t.footer.legal || "Legal"}</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/privacy" className="hover:text-pink-600">{t.footer.privacy || "Privacy Policy"}</Link>
            </li>
            <li>
              <Link href="/terms" className="hover:text-pink-600">{t.footer.terms || "Terms of Service"}</Link>
            </li>
            <li className="pt-2">
              <p className="text-xs text-gray-400">{t.footer.copyright || "© 2024 Amoura. All rights reserved."}</p>
            </li>
          </ul>
        </div>
      </div>
    </footer>
  );
}