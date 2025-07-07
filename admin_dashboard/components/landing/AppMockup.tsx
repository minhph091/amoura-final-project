"use client";

import React, { useState, useEffect } from "react";
import { Heart, MessageCircle, User, Star, MapPin, Camera } from "lucide-react";

interface AppMockupProps {
  language: string;
}

export function AppMockup({ language }: AppMockupProps) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const mockupScreens = [
    {
      id: "discover",
      title: language === "vi" ? "Khám phá" : "Discover",
      content: (
        <img
          src="/camera-roll/screenshot1.png"
          alt="Khám phá"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
    {
      id: "vip",
      title: language === "vi" ? "Tính năng VIP" : "VIP Feature",
      content: (
        <img
          src="/camera-roll/screenshot2.png"
          alt="Tính năng VIP"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
    {
      id: "chat-list",
      title: language === "vi" ? "Danh sách Trò chuyện" : "Chat List",
      content: (
        <img
          src="/camera-roll/screenshot3.png"
          alt="Danh sách Trò chuyện"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
    {
      id: "chat",
      title: language === "vi" ? "Trò chuyện" : "Chat",
      content: (
        <img
          src="/camera-roll/screenshot4.png"
          alt="Trò chuyện"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
    {
      id: "notification",
      title: language === "vi" ? "Thông báo" : "Notification",
      content: (
        <img
          src="/camera-roll/screenshot5.png"
          alt="Thông báo"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
    {
      id: "profile",
      title: language === "vi" ? "Hồ sơ" : "Profile",
      content: (
        <img
          src="/camera-roll/screenshot6.png"
          alt="Hồ sơ"
          className="w-full h-full object-cover rounded-2xl"
        />
      ),
    },
  ];

  // Auto slide carousel
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % mockupScreens.length);
    }, 4000);
    return () => clearInterval(interval);
  }, [mockupScreens.length]);

  return (
    <div className="mt-16 scroll-animation opacity-0 translate-y-10">
      <div className="relative max-w-sm mx-auto">
        <div className="bg-slate-900 dark:bg-slate-800 rounded-[3rem] p-3 shadow-2xl">
          <div
            className="bg-black rounded-[2.5rem] relative overflow-hidden"
            style={{ aspectRatio: "9/19.5" }}
          >
            {/* Phone notch */}
            <div className="absolute top-3 left-1/2 transform -translate-x-1/2 w-1/3 h-6 bg-slate-900 dark:bg-slate-800 rounded-b-2xl z-10"></div>

            {/* Slides */}
            <div
              className="flex h-full transition-transform duration-700 ease-in-out"
              style={{
                transform: `translateX(-${currentSlide * 100}%)`,
              }}
            >
              {mockupScreens.map((screen, index) => (
                <div key={screen.id} className="w-full h-full flex-shrink-0">
                  {screen.content}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Carousel indicators */}
        <div className="flex justify-center mt-6 space-x-2">
          {mockupScreens.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentSlide(index)}
              className={`w-3 h-3 rounded-full transition ${
                index === currentSlide
                  ? "bg-pink-500"
                  : "bg-slate-300 dark:bg-slate-600"
              }`}
            />
          ))}
        </div>

        {/* Screen labels */}
        <div className="text-center mt-4">
          <p className="text-sm text-slate-600 dark:text-slate-400 font-medium">
            {mockupScreens[currentSlide].title}
          </p>
        </div>
      </div>
    </div>
  );
}
