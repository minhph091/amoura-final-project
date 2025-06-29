"use client";

import React, { useState, useEffect } from "react";

interface PhoneMockupProps {
  language: string;
}

export function PhoneMockup({ language }: PhoneMockupProps) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const phoneSlides = [
    {
      bg: "bg-gradient-to-br from-pink-100 to-purple-100",
      text: language === "vi" ? "Quẹt để tìm kiếm" : "Swipe to Match",
    },
    {
      bg: "bg-gradient-to-br from-purple-100 to-blue-100",
      text: language === "vi" ? "Trò chuyện thú vị" : "Engaging Chats",
    },
    {
      bg: "bg-gradient-to-br from-green-100 to-teal-100",
      text: language === "vi" ? "Hồ sơ ấn tượng" : "Impressive Profile",
    },
  ];

  // Auto slide carousel
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % phoneSlides.length);
    }, 3000);
    return () => clearInterval(interval);
  }, [phoneSlides.length]);

  return (
    <div className="mt-16 scroll-animation opacity-0 translate-y-10">
      <div className="relative max-w-sm mx-auto">
        <div className="bg-slate-800 rounded-[3rem] p-3 shadow-2xl">
          <div
            className="bg-black rounded-[2.5rem] relative overflow-hidden"
            style={{ aspectRatio: "9/19.5" }}
          >
            {/* Phone notch */}
            <div className="absolute top-3 left-1/2 transform -translate-x-1/2 w-1/3 h-6 bg-slate-800 rounded-b-2xl z-10"></div>

            {/* Slides */}
            <div
              className="flex h-full transition-transform duration-500 ease-in-out"
              style={{
                transform: `translateX(-${currentSlide * 100}%)`,
              }}
            >
              {phoneSlides.map((slide, index) => (
                <div
                  key={index}
                  className={`w-full h-full flex-shrink-0 ${slide.bg} flex items-center justify-center`}
                >
                  <div className="text-slate-700 font-semibold text-lg text-center px-8">
                    {slide.text}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Carousel dots */}
        <div className="flex justify-center mt-6 space-x-2">
          {phoneSlides.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentSlide(index)}
              className={`w-3 h-3 rounded-full transition ${
                index === currentSlide ? "bg-pink-500" : "bg-slate-300"
              }`}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
