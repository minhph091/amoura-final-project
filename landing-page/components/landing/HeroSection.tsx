"use client";

import React from "react";
import { Heart, MessageSquareHeart, Sparkles } from "lucide-react";

interface HeroSectionProps {
  t: any;
  language: string;
}

export function HeroSection({ t, language }: HeroSectionProps) {
  return (
    <section className="py-16 md:py-20 overflow-hidden relative">
      {/* Enhanced background with gradients */}
      <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900"></div>

      {/* Animated gradient orbs */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-72 h-72 bg-gradient-to-r from-pink-400/30 to-rose-400/30 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute top-40 right-20 w-64 h-64 bg-gradient-to-r from-purple-400/30 to-pink-400/30 rounded-full blur-3xl animate-bounce"></div>
        <div className="absolute bottom-20 left-20 w-48 h-48 bg-gradient-to-r from-blue-400/30 to-purple-400/30 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-60 left-1/2 w-56 h-56 bg-gradient-to-r from-rose-400/20 to-pink-400/20 rounded-full blur-3xl animate-bounce delay-500"></div>
      </div>

      {/* Floating hearts animation */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-32 left-1/4 text-pink-300 dark:text-pink-600 animate-float">
          <Heart className="w-6 h-6 fill-current" />
        </div>
        <div className="absolute top-48 right-1/3 text-rose-300 dark:text-rose-600 animate-float-delayed">
          <Sparkles className="w-8 h-8" />
        </div>
        <div className="absolute bottom-40 left-1/3 text-purple-300 dark:text-purple-600 animate-float">
          <Heart className="w-4 h-4 fill-current" />
        </div>
      </div>

      <div className="container mx-auto px-6 text-center relative z-10">
        <div className="max-w-4xl mx-auto relative">
          {/* Premium badge */}
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-rose-500 text-white px-6 py-2 rounded-full text-sm font-semibold mb-8 shadow-lg animate-fade-in">
            <Sparkles className="w-4 h-4" />
            {language === "vi"
              ? "Ứng dụng hẹn hò #1 Việt Nam"
              : "#1 Dating App in Vietnam"}
          </div>

          <h1 className="text-4xl md:text-6xl lg:text-7xl font-extrabold leading-tight mb-6">
            <span className="bg-gradient-to-r from-slate-800 via-slate-700 to-slate-800 dark:from-slate-100 dark:via-slate-200 dark:to-slate-100 bg-clip-text text-transparent">
              {t.heroTitle}
            </span>
            <br />
            <span className="bg-gradient-to-r from-pink-500 via-rose-500 to-pink-600 bg-clip-text text-transparent">
              {t.heroTitleHighlight}
            </span>
            <br />
            <span className="bg-gradient-to-r from-slate-800 via-slate-700 to-slate-800 dark:from-slate-100 dark:via-slate-200 dark:to-slate-100 bg-clip-text text-transparent">
              {t.heroTitleEnd}
            </span>
          </h1>

          <p className="text-lg md:text-xl text-slate-600 dark:text-slate-300 mb-10 max-w-2xl mx-auto leading-relaxed">
            {t.heroSubtitle}
          </p>

          <div className="flex flex-col sm:flex-row justify-center items-center gap-4 mb-16">
            <a
              href="#download"
              className="group bg-gradient-to-r from-pink-500 to-rose-500 text-white px-8 py-4 rounded-full font-bold text-lg transition-all duration-300 transform hover:-translate-y-2 hover:shadow-2xl w-full sm:w-auto flex items-center justify-center gap-2 shadow-lg"
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
              <Heart className="w-5 h-5 group-hover:animate-pulse" />
              {t.heroCtaPrimary}
            </a>
            <a
              href="#chat-web"
              className="group bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm text-pink-500 dark:text-pink-400 border-2 border-pink-200 dark:border-pink-600 px-8 py-4 rounded-full font-bold text-lg transition-all duration-300 transform hover:-translate-y-2 hover:shadow-2xl w-full sm:w-auto flex items-center justify-center gap-2"
              onClick={(e) => {
                e.preventDefault();
                const chatSection = document.getElementById("chat-web");
                if (chatSection) {
                  chatSection.scrollIntoView({ behavior: "smooth" });
                  // Force show animations
                  setTimeout(() => {
                    const chatElements = document.querySelectorAll("#chat-web");
                    chatElements.forEach((el) => {
                      el.classList.remove("opacity-0", "translate-y-10");
                      el.classList.add("opacity-100", "translate-y-0");
                    });
                  }, 300);
                }
              }}
            >
              <MessageSquareHeart className="w-5 h-5 group-hover:animate-pulse" />
              {t.heroCtaSecondary}
            </a>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 mb-16 max-w-2xl mx-auto">
            <div className="text-center">
              <div className="text-3xl font-bold text-pink-500 dark:text-pink-400">
                1M+
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {language === "vi" ? "Người dùng" : "Users"}
              </div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-rose-500 dark:text-rose-400">
                500K+
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {language === "vi"
                  ? "Kết đôi thành công"
                  : "Successful Matches"}
              </div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-purple-500 dark:text-purple-400">
                10K+
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {language === "vi" ? "Đánh giá 5 sao" : "5-Star Reviews"}
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        @keyframes float {
          0%,
          100% {
            transform: translateY(0px);
          }
          50% {
            transform: translateY(-20px);
          }
        }

        @keyframes float-delayed {
          0%,
          100% {
            transform: translateY(0px);
          }
          50% {
            transform: translateY(-15px);
          }
        }

        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .animate-float {
          animation: float 3s ease-in-out infinite;
        }

        .animate-float-delayed {
          animation: float-delayed 4s ease-in-out infinite;
        }

        .animate-fade-in {
          animation: fade-in 1s ease-out;
        }
      `}</style>
    </section>
  );
}
