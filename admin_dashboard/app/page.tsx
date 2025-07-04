"use client";

import React, { useState, useEffect } from "react";
import {
  Header,
  HeroSection,
  FeaturesSection,
  HowItWorksSection,
  TestimonialsSection,
  StatsSection,
  DownloadSection,
  FAQSection,
  Footer,
  translations,
} from "@/components/landing";

export default function LandingPage() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [language, setLanguage] = useState("vi");

  const t = translations[language as keyof typeof translations];

  // Scroll animation
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.remove("opacity-0", "translate-y-10");
            entry.target.classList.add("opacity-100", "translate-y-0");
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll(".scroll-animation");
    elements.forEach((el) => observer.observe(el));

    // Handle hash navigation (when clicking #download links)
    const handleHashChange = () => {
      const hash = window.location.hash;
      if (hash === "#download") {
        setTimeout(() => {
          const downloadElements = document.querySelectorAll(
            "#download .scroll-animation"
          );
          downloadElements.forEach((el) => {
            el.classList.remove("opacity-0", "translate-y-10");
            el.classList.add("opacity-100", "translate-y-0");
          });
        }, 100);
      }
    };

    // Check on mount
    setTimeout(() => {
      handleHashChange();
    }, 100);

    // Listen for hash changes
    window.addEventListener("hashchange", handleHashChange);

    return () => {
      observer.disconnect();
      window.removeEventListener("hashchange", handleHashChange);
    };
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
      <Header
        language={language}
        setLanguage={setLanguage}
        isMenuOpen={isMenuOpen}
        setIsMenuOpen={setIsMenuOpen}
        t={t}
      />

      <main className="pt-24">
        <HeroSection t={t} language={language} />
        <FeaturesSection t={t} />
        <HowItWorksSection t={t} />
        <TestimonialsSection t={t} />
        <StatsSection t={t} />
        <DownloadSection t={t} />
        <FAQSection t={t} />
      </main>

      <Footer t={t} />

      <style jsx>{`
        .scroll-animation {
          transition: opacity 0.8s ease-out, transform 0.8s ease-out;
        }

        .animate-fade-in-up {
          animation: fadeInUp 0.8s ease-out forwards;
        }

        @keyframes fadeInUp {
          from {
            opacity: 0;
            transform: translateY(40px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>
    </div>
  );
}
