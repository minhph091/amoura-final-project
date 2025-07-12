"use client";

import * as React from "react";
import ReactCountryFlag from "react-country-flag";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useLanguage } from "@/src/contexts/LanguageContext";

const languages = [
  {
    code: "en",
    name: "English",
    flag: "US",
  },
  {
    code: "vi",
    name: "Tiếng Việt",
    flag: "VN",
  },
];

export function LanguageSwitcher() {
  const { language, setLanguage } = useLanguage();

  const currentLanguage = languages.find((lang) => lang.code === language);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="sm" className="h-8 gap-2 px-3">
          <ReactCountryFlag
            countryCode={currentLanguage?.flag || "US"}
            svg
            style={{
              width: "1.2em",
              height: "1.2em",
            }}
          />
          <span className="hidden sm:inline-flex">{currentLanguage?.name}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-[180px]">
        {languages.map((lang) => (
          <DropdownMenuItem
            key={lang.code}
            onClick={() => setLanguage(lang.code as "en" | "vi")}
            className="gap-2 cursor-pointer"
          >
            <ReactCountryFlag
              countryCode={lang.flag}
              svg
              style={{
                width: "1.5em",
                height: "1.5em",
              }}
            />
            <span>{lang.name}</span>
            {language === lang.code && (
              <span className="ml-auto text-sm text-muted-foreground">✓</span>
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
