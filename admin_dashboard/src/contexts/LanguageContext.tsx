"use client";

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from "react";
import { dashboardTranslations } from "@/src/translations/dashboard";

type Language = "vi" | "en";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: typeof dashboardTranslations.vi;
}

const LanguageContext = createContext<LanguageContextType | undefined>(
  undefined
);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguage] = useState<Language | undefined>(undefined);

  // Load language from localStorage on mount
  useEffect(() => {
    const savedLanguage = localStorage.getItem("adminLanguage") as Language;
    if (savedLanguage && (savedLanguage === "vi" || savedLanguage === "en")) {
      setLanguage(savedLanguage);
    } else {
      setLanguage("vi"); // fallback default
    }
  }, []);

  // Save language to localStorage when changed
  useEffect(() => {
    if (language) {
      localStorage.setItem("adminLanguage", language);
    }
  }, [language]);

  const t = dashboardTranslations[language || "vi"];

  const value: LanguageContextType = {
    language: language || "vi",
    setLanguage,
    t,
  };

  if (!language) {
    // Avoid rendering children until language is loaded
    return null;
  }

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage(): LanguageContextType {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}
