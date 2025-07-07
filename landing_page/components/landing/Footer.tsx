"use client";

import React from "react";
import { Facebook, Instagram, Twitter } from "lucide-react";
import { AmouraLogo } from "@/components/ui/AmouraLogo";

interface FooterProps {
  t: any;
}

export function Footer({ t }: FooterProps) {
  return (
    <footer className="bg-slate-800 dark:bg-slate-950 text-white">
      <div className="container mx-auto px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="md:col-span-1">
            <div className="flex items-center gap-3 mb-4">
              <AmouraLogo size="small" />
            </div>
            <p className="text-slate-400 dark:text-slate-500">
              {t.footerTagline}
            </p>
            <div className="flex space-x-4 mt-6">
              <a
                href="#"
                className="text-slate-400 dark:text-slate-500 hover:text-white dark:hover:text-slate-300 transition"
              >
                <Facebook className="w-5 h-5" />
              </a>
              <a
                href="#"
                className="text-slate-400 dark:text-slate-500 hover:text-white dark:hover:text-slate-300 transition"
              >
                <Instagram className="w-5 h-5" />
              </a>
              <a
                href="#"
                className="text-slate-400 dark:text-slate-500 hover:text-white dark:hover:text-slate-300 transition"
              >
                <Twitter className="w-5 h-5" />
              </a>
            </div>
          </div>
          <div>
            <h4 className="font-bold mb-4">{t.footerProduct}</h4>
            <ul className="space-y-2 text-slate-400 dark:text-slate-500">
              <li>
                <a
                  href="#features"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerFeatures}
                </a>
              </li>
              <li>
                <a
                  href="#download"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerDownload}
                </a>
              </li>
              <li>
                <a
                  href="#chat-web"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerWebChat}
                </a>
              </li>
            </ul>
          </div>
          <div>
            <h4 className="font-bold mb-4">{t.footerCompany}</h4>
            <ul className="space-y-2 text-slate-400 dark:text-slate-500">
              <li>
                <a
                  href="#"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerAbout}
                </a>
              </li>
              <li>
                <a
                  href="#"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerCareers}
                </a>
              </li>
              <li>
                <a
                  href="#"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerPress}
                </a>
              </li>
            </ul>
          </div>
          <div>
            <h4 className="font-bold mb-4">{t.footerLegal}</h4>
            <ul className="space-y-2 text-slate-400 dark:text-slate-500">
              <li>
                <a
                  href="/terms"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.termsOfService}
                </a>
              </li>
              <li>
                <a
                  href="/privacy"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.privacyPolicy}
                </a>
              </li>
              <li>
                <a
                  href="#"
                  className="hover:text-white dark:hover:text-slate-300 transition"
                >
                  {t.footerContact}
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-12 border-t border-slate-700 dark:border-slate-800 pt-8 text-center text-slate-500 dark:text-slate-600">
          <p>&copy; 2025 Amoura. {t.footerRights}</p>
        </div>
      </div>
    </footer>
  );
}
