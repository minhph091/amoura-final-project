"use client";

import { useLanguage } from "@/src/contexts/LanguageContext";
import { useEffect, useRef } from "react";

export function LanguageDebug() {
  const { language } = useLanguage();
  const renderCount = useRef(0);

  useEffect(() => {
    renderCount.current += 1;
    console.log(`[LanguageDebug] Render #${renderCount.current}, Language: ${language}`);
  }, [language]);

  return (
    <div className="fixed bottom-4 left-4 bg-black/80 text-white text-xs p-2 rounded z-50">
      Lang: {language} | Renders: {renderCount.current}
    </div>
  );
}
