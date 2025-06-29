"use client";

import React, { useState, useRef, useEffect } from "react";
import { Sun, Moon, Monitor, ChevronDown } from "lucide-react";
import { useTheme } from "next-themes";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const [isOpen, setIsOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const themes = [
    { value: "light", icon: Sun, label: "Sáng", labelEn: "Light" },
    { value: "dark", icon: Moon, label: "Tối", labelEn: "Dark" },
    { value: "system", icon: Monitor, label: "Hệ thống", labelEn: "System" },
  ];

  const currentTheme = themes.find((t) => t.value === theme) || themes[2]; // Default to system theme

  // Handle mounting to prevent hydration mismatch
  useEffect(() => {
    setMounted(true);
  }, []);

  // Handle click outside - must be called consistently
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false);
      }
    }

    if (mounted) {
      document.addEventListener("mousedown", handleClickOutside);
      return () => {
        document.removeEventListener("mousedown", handleClickOutside);
      };
    }
  }, [mounted]);

  // Prevent hydration mismatch by not rendering until mounted
  if (!mounted) {
    return (
      <div className="relative">
        <button className="flex items-center gap-2 px-3 py-2 text-slate-600 dark:text-slate-400 hover:text-pink-500 transition-colors rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800">
          <Monitor className="w-4 h-4" />
          <span className="text-sm font-medium hidden sm:inline">Hệ thống</span>
          <ChevronDown className="w-4 h-4" />
        </button>
      </div>
    );
  }

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-3 py-2 text-slate-600 dark:text-slate-400 hover:text-pink-500 transition-colors rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800"
      >
        <currentTheme.icon className="w-4 h-4" />
        <span className="text-sm font-medium hidden sm:inline">
          {currentTheme.label}
        </span>
        <ChevronDown
          className={`w-4 h-4 transition-transform ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>

      {isOpen && (
        <div className="absolute top-full right-0 mt-2 bg-white dark:bg-slate-800 rounded-lg shadow-lg border border-slate-200 dark:border-slate-700 py-2 min-w-[150px] z-50">
          {themes.map((themeOption) => {
            const Icon = themeOption.icon;
            return (
              <button
                key={themeOption.value}
                onClick={() => {
                  setTheme(themeOption.value);
                  setIsOpen(false);
                }}
                className={`w-full flex items-center gap-3 px-4 py-2 text-left hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors ${
                  theme === themeOption.value
                    ? "bg-pink-50 dark:bg-pink-900/20 text-pink-600 dark:text-pink-400"
                    : "text-slate-700 dark:text-slate-300"
                }`}
              >
                <Icon className="w-4 h-4" />
                <div className="flex-1">
                  <div className="font-medium">{themeOption.label}</div>
                  <div className="text-xs text-slate-500 dark:text-slate-400">
                    {themeOption.labelEn}
                  </div>
                </div>
                {theme === themeOption.value && (
                  <div className="w-2 h-2 bg-pink-500 rounded-full"></div>
                )}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
