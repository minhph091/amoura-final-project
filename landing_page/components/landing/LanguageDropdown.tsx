"use client";

import React, { useState, useRef, useEffect } from "react";
import ReactCountryFlag from "react-country-flag";
import { ChevronDown, Globe } from "lucide-react";

interface LanguageDropdownProps {
  language: string;
  setLanguage: (lang: string) => void;
}

export function LanguageDropdown({
  language,
  setLanguage,
}: LanguageDropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const languages = [
    {
      code: "vi",
      name: "Tiếng Việt",
      flag: "VN",
    },
    {
      code: "en",
      name: "English",
      flag: "US",
    },
  ];

  const currentLanguage =
    languages.find((lang) => lang.code === language) || languages[0];

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-3 py-2 text-slate-600 hover:text-pink-500 transition-colors rounded-lg hover:bg-slate-50"
      >
        <Globe className="w-4 h-4" />
        <ReactCountryFlag
          countryCode={currentLanguage.flag}
          svg
          style={{
            width: "1.2em",
            height: "1.2em",
          }}
        />
        <span className="text-sm font-medium">
          {currentLanguage.code.toUpperCase()}
        </span>
        <ChevronDown
          className={`w-4 h-4 transition-transform ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>

      {isOpen && (
        <div className="absolute top-full right-0 mt-2 bg-white rounded-lg shadow-lg border border-slate-200 py-2 min-w-[180px] z-50">
          {languages.map((lang) => (
            <button
              key={lang.code}
              onClick={() => {
                setLanguage(lang.code);
                setIsOpen(false);
              }}
              className={`w-full flex items-center gap-3 px-4 py-2 text-left hover:bg-slate-50 transition-colors ${
                language === lang.code
                  ? "bg-pink-50 text-pink-600"
                  : "text-slate-700"
              }`}
            >
              <ReactCountryFlag
                countryCode={lang.flag}
                svg
                style={{
                  width: "1.5em",
                  height: "1.5em",
                }}
              />
              <div>
                <div className="font-medium">{lang.name}</div>
                <div className="text-xs text-slate-500">
                  {lang.code.toUpperCase()}
                </div>
              </div>
              {language === lang.code && (
                <div className="ml-auto w-2 h-2 bg-pink-500 rounded-full"></div>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
