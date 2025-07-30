
"use client";
import Link from "next/link";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { authService } from "@/src/services/auth.service";
import { useEffect, useState } from "react";

export default function Footer() {
  const [role, setRole] = useState<string | null>(null);
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
            Amoura Admin Dashboard - Manage your dating platform with powerful tools and insights.
          </p>
          <p className="text-xs text-gray-400">Made with <span className="text-pink-500">♥</span> for administrators</p>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">Quick Links</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/dashboard" className="hover:text-pink-600">Dashboard</Link>
            </li>
            <li>
              <Link href="/dashboard/users" className="hover:text-pink-600">Users</Link>
            </li>
            {isAdmin && (
              <>
                <li>
                  <Link href="/dashboard/moderators" className="hover:text-pink-600">Moderators</Link>
                </li>
                <li>
                  <Link href="/add-account" className="hover:text-pink-600">Add Account</Link>
                </li>
              </>
            )}
            <li>
              <Link href="/dashboard/settings" className="hover:text-pink-600">Settings</Link>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">Support</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/help" className="hover:text-pink-600">Help Center</Link>
            </li>
            <li>
              <Link href="/privacy" className="hover:text-pink-600">Privacy Policy</Link>
            </li>
            <li>
              <Link href="/terms" className="hover:text-pink-600">Terms of Service</Link>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="font-semibold text-gray-800 mb-3">Legal</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/privacy" className="hover:text-pink-600">Privacy Policy</Link>
            </li>
            <li>
              <Link href="/terms" className="hover:text-pink-600">Terms of Service</Link>
            </li>
          </ul>
        </div>
      </div>
    </footer>
  );
}