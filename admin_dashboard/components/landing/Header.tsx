"use client";

import React from "react";
import { useRouter } from "next/navigation";
import { Menu, X } from "lucide-react";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { LanguageDropdown } from "./LanguageDropdown";
import { ThemeToggle } from "./ThemeToggle";

interface HeaderProps {
  language: string;
  setLanguage: (lang: string) => void;
  isMenuOpen: boolean;
  setIsMenuOpen: (open: boolean) => void;
  t: any;
}

export function Header({
  language,
  setLanguage,
  isMenuOpen,
  setIsMenuOpen,
  t,
}: HeaderProps) {
  const router = useRouter();

  return (
    <header className="bg-white/80 dark:bg-slate-900/80 backdrop-blur-lg fixed top-0 left-0 right-0 z-50 shadow-sm border-b border-slate-200/50 dark:border-slate-700/50">
      <div className="container mx-auto px-6 py-3 flex justify-between items-center">
        <div className="flex items-center gap-3">
          <AmouraLogo size="medium" />
        </div>

        <nav className="hidden md:flex items-center space-x-6">
          <a
            href="#features"
            className="text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400 transition"
          >
            {t.navFeatures}
          </a>
          <a
            href="#how-it-works"
            className="text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400 transition"
          >
            {t.navHowItWorks}
          </a>
          <a
            href="#testimonials"
            className="text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400 transition"
          >
            {t.navTestimonials}
          </a>

          <div className="flex items-center space-x-4 border-l border-slate-200 dark:border-slate-700 pl-4">
            <LanguageDropdown language={language} setLanguage={setLanguage} />
            <ThemeToggle />
          </div>

          <button
            onClick={() => router.push("/login")}
            className="bg-slate-600 dark:bg-slate-700 text-white px-4 py-2 rounded-full font-semibold hover:bg-slate-700 dark:hover:bg-slate-600 transition"
          >
            {t.adminLogin}
          </button>

          <a
            href="#download"
            className="bg-pink-500 text-white px-5 py-2 rounded-full font-semibold hover:bg-pink-600 transition transform hover:-translate-y-1"
            onClick={(e) => {
              e.preventDefault();
              const downloadSection = document.getElementById("download");
              if (downloadSection) {
                downloadSection.scrollIntoView({ behavior: "smooth" });
                // Force show animations
                setTimeout(() => {
                  const downloadElements = document.querySelectorAll(
                    "#download .scroll-animation"
                  );
                  downloadElements.forEach((el) => {
                    el.classList.remove("opacity-0", "translate-y-10");
                    el.classList.add("opacity-100", "translate-y-0");
                  });
                }, 300);
              }
            }}
          >
            {t.navStartNow}
          </a>
        </nav>

        <button
          className="md:hidden text-slate-600 dark:text-slate-300"
          onClick={() => setIsMenuOpen(!isMenuOpen)}
        >
          {isMenuOpen ? <X /> : <Menu />}
        </button>
      </div>

      {/* Mobile Menu */}
      {isMenuOpen && (
        <div className="md:hidden bg-white dark:bg-slate-900 shadow-lg border-t border-slate-200 dark:border-slate-700">
          <div className="px-6 py-4 space-y-4">
            <a
              href="#features"
              className="block text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400"
            >
              {t.navFeatures}
            </a>
            <a
              href="#how-it-works"
              className="block text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400"
            >
              {t.navHowItWorks}
            </a>
            <a
              href="#testimonials"
              className="block text-slate-600 dark:text-slate-300 hover:text-pink-500 dark:hover:text-pink-400"
            >
              {t.navTestimonials}
            </a>

            <div className="flex items-center justify-between pt-4 border-t border-slate-200 dark:border-slate-700">
              <LanguageDropdown language={language} setLanguage={setLanguage} />
              <ThemeToggle />
            </div>

            <button
              onClick={() => router.push("/login")}
              className="block w-full text-left bg-slate-600 dark:bg-slate-700 text-white px-4 py-2 rounded-full"
            >
              {t.adminLogin}
            </button>
            <a
              href="#download"
              className="block bg-pink-500 text-white px-4 py-2 rounded-full text-center"
              onClick={(e) => {
                e.preventDefault();
                setIsMenuOpen(false);
                const downloadSection = document.getElementById("download");
                if (downloadSection) {
                  downloadSection.scrollIntoView({ behavior: "smooth" });
                  // Force show animations
                  setTimeout(() => {
                    const downloadElements = document.querySelectorAll(
                      "#download .scroll-animation"
                    );
                    downloadElements.forEach((el) => {
                      el.classList.remove("opacity-0", "translate-y-10");
                      el.classList.add("opacity-100", "translate-y-0");
                    });
                  }, 300);
                }
              }}
            >
              {t.navStartNow}
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
