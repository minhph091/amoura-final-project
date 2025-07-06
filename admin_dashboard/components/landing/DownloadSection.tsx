"use client";

import React from "react";
import { MessageSquareHeart, Smartphone, Play } from "lucide-react";

interface DownloadSectionProps {
  t: any;
}

export function DownloadSection({ t }: DownloadSectionProps) {
  return (
    <section id="download" className="py-16 relative overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900"></div>

      {/* Decorative elements */}
      <div className="absolute top-20 left-10 w-40 h-40 bg-gradient-to-r from-pink-200/30 to-rose-200/30 rounded-full blur-3xl"></div>
      <div className="absolute bottom-20 right-10 w-48 h-48 bg-gradient-to-r from-purple-200/30 to-pink-200/30 rounded-full blur-3xl"></div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="bg-white/90 dark:bg-slate-800/90 backdrop-blur-sm rounded-3xl shadow-2xl p-10 md:p-16 flex flex-col lg:flex-row items-center justify-between gap-8 scroll-animation opacity-0 translate-y-10 transition-all duration-800 border border-white/20 dark:border-slate-700/20">
          <div className="text-center lg:text-left">
            <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-slate-800 to-slate-600 dark:from-slate-100 dark:to-slate-300 bg-clip-text text-transparent mb-4">
              {t.downloadTitle}
            </h2>
            <p className="text-slate-600 dark:text-slate-300 text-lg leading-relaxed">
              {t.downloadSubtitle}
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-4 w-full lg:w-auto shrink-0">
            {/* App Store Button */}
            <a
              href="#"
              className="group bg-black dark:bg-slate-900 text-white px-6 py-3 rounded-xl font-semibold flex items-center justify-center gap-3 hover:bg-gray-800 dark:hover:bg-slate-800 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl w-full"
            >
              <div className="w-8 h-8 flex items-center justify-center">
                <svg
                  className="w-8 h-8"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
              </div>
              <div className="text-left">
                <p className="text-xs opacity-80">
                  {t.downloadOn || "Download on the"}
                </p>
                <p className="text-lg font-bold">App Store</p>
              </div>
            </a>

            {/* Google Play Button */}
            <a
              href="#"
              className="group bg-black dark:bg-slate-900 text-white px-6 py-3 rounded-xl font-semibold flex items-center justify-center gap-3 hover:bg-gray-800 dark:hover:bg-slate-800 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl w-full"
            >
              <div className="w-8 h-8 flex items-center justify-center">
                <Play className="w-8 h-8" />
              </div>
              <div className="text-left">
                <p className="text-xs opacity-80">{t.getThe || "Get it on"}</p>
                <p className="text-lg font-bold">Google Play</p>
              </div>
            </a>
          </div>
        </div>

        {/* Web Chat Section */}
        <div
          id="chat-web"
          className="mt-12 text-center scroll-animation opacity-0 translate-y-10 transition-all duration-800"
        >
          <p className="text-slate-700 dark:text-slate-300 mb-6 text-lg">
            {t.webChatPrompt}
          </p>
          <a
            href="#"
            className="inline-flex items-center gap-3 bg-gradient-to-r from-pink-500 to-rose-500 text-white px-10 py-4 rounded-full font-bold text-lg transition-all duration-300 transform hover:-translate-y-2 hover:shadow-2xl"
          >
            <MessageSquareHeart className="w-6 h-6" />
            {t.webChatCta}
          </a>
        </div>

        {/* Additional features */}
        <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="text-center p-6 bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm rounded-2xl border border-white/20 dark:border-slate-700/20">
            <div className="w-12 h-12 bg-gradient-to-r from-green-400 to-blue-500 rounded-full mx-auto mb-4 flex items-center justify-center">
              <span className="text-white font-bold">✓</span>
            </div>
            <h3 className="font-bold text-slate-800 dark:text-slate-100 mb-2">
              {t.downloadFree}
            </h3>
            <p className="text-slate-600 dark:text-slate-300 text-sm">
              {t.downloadFreeDesc}
            </p>
          </div>

          <div className="text-center p-6 bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm rounded-2xl border border-white/20 dark:border-slate-700/20">
            <div className="w-12 h-12 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full mx-auto mb-4 flex items-center justify-center">
              <span className="text-white font-bold">⚡</span>
            </div>
            <h3 className="font-bold text-slate-800 dark:text-slate-100 mb-2">
              {t.downloadFast}
            </h3>
            <p className="text-slate-600 dark:text-slate-300 text-sm">
              {t.downloadFastDesc}
            </p>
          </div>

          <div className="text-center p-6 bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm rounded-2xl border border-white/20 dark:border-slate-700/20">
            <div className="w-12 h-12 bg-gradient-to-r from-orange-400 to-red-500 rounded-full mx-auto mb-4 flex items-center justify-center">
              <span className="text-white font-bold">🔒</span>
            </div>
            <h3 className="font-bold text-slate-800 dark:text-slate-100 mb-2">
              {t.downloadSecure}
            </h3>
            <p className="text-slate-600 dark:text-slate-300 text-sm">
              {t.downloadSecureDesc}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
