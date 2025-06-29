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
        <div className="h-full bg-gradient-to-b from-pink-400 to-rose-500 flex flex-col">
          {/* Header */}
          <div className="flex justify-between items-center p-4 text-white">
            <MapPin className="w-5 h-5" />
            <h2 className="font-bold">Amoura</h2>
            <Camera className="w-5 h-5" />
          </div>

          {/* Profile Card */}
          <div className="flex-1 relative overflow-hidden mx-4 mb-20">
            <div className="bg-white rounded-2xl h-full shadow-2xl relative overflow-hidden">
              <div className="h-3/4 bg-gradient-to-br from-purple-200 to-pink-200 relative">
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="w-32 h-32 bg-gradient-to-r from-pink-400 to-purple-400 rounded-full flex items-center justify-center">
                    <User className="w-16 h-16 text-white" />
                  </div>
                </div>
                <div className="absolute bottom-4 left-4 text-slate-700">
                  <h3 className="text-xl font-bold">Mai Anh, 24</h3>
                  <p className="text-sm opacity-75">Designer • Hà Nội</p>
                </div>
              </div>
              <div className="h-1/4 p-4 flex justify-center space-x-4">
                <button className="w-12 h-12 bg-slate-200 rounded-full flex items-center justify-center">
                  <span className="text-2xl">✕</span>
                </button>
                <button className="w-16 h-16 bg-pink-500 rounded-full flex items-center justify-center">
                  <Heart className="w-8 h-8 text-white fill-current" />
                </button>
                <button className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center">
                  <Star className="w-6 h-6 text-white" />
                </button>
              </div>
            </div>
          </div>
        </div>
      ),
    },
    {
      id: "chat",
      title: language === "vi" ? "Trò chuyện" : "Chat",
      content: (
        <div className="h-full bg-slate-50 flex flex-col">
          {/* Header */}
          <div className="bg-white border-b p-4 flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-r from-pink-400 to-purple-400 rounded-full flex items-center justify-center">
              <User className="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 className="font-semibold">Mai Anh</h3>
              <p className="text-xs text-green-500">● Online</p>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 p-4 space-y-4">
            <div className="flex justify-end">
              <div className="bg-pink-500 text-white px-4 py-2 rounded-2xl rounded-tr-md max-w-xs">
                <p className="text-sm">Chào bạn! 👋</p>
              </div>
            </div>
            <div className="flex justify-start">
              <div className="bg-white px-4 py-2 rounded-2xl rounded-tl-md max-w-xs shadow-sm">
                <p className="text-sm">Chào! Rất vui được kết đôi với bạn 😊</p>
              </div>
            </div>
            <div className="flex justify-end">
              <div className="bg-pink-500 text-white px-4 py-2 rounded-2xl rounded-tr-md max-w-xs">
                <p className="text-sm">Bạn có thích cà phê không?</p>
              </div>
            </div>
          </div>

          {/* Input */}
          <div className="bg-white border-t p-4 flex items-center space-x-2">
            <div className="flex-1 bg-slate-100 rounded-full px-4 py-2">
              <span className="text-slate-400 text-sm">Nhập tin nhắn...</span>
            </div>
            <button className="w-8 h-8 bg-pink-500 rounded-full flex items-center justify-center">
              <MessageCircle className="w-4 h-4 text-white" />
            </button>
          </div>
        </div>
      ),
    },
    {
      id: "profile",
      title: language === "vi" ? "Hồ sơ" : "Profile",
      content: (
        <div className="h-full bg-white flex flex-col">
          {/* Header */}
          <div className="bg-gradient-to-r from-pink-500 to-purple-500 p-6 text-white">
            <div className="text-center">
              <div className="w-20 h-20 bg-white/20 rounded-full mx-auto mb-3 flex items-center justify-center">
                <User className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-xl font-bold">Minh Hoàng</h2>
              <p className="opacity-90">Software Engineer • 26 tuổi</p>
            </div>
          </div>

          {/* Content */}
          <div className="flex-1 p-6 space-y-4">
            <div className="flex items-center justify-between py-2">
              <span className="text-slate-600">Đã xác thực</span>
              <div className="flex space-x-1">
                {[...Array(5)].map((_, i) => (
                  <div
                    key={i}
                    className="w-2 h-2 bg-green-500 rounded-full"
                  ></div>
                ))}
              </div>
            </div>

            <div>
              <h3 className="font-semibold mb-2">Sở thích</h3>
              <div className="flex flex-wrap gap-2">
                {["🎵 Âm nhạc", "📚 Đọc sách", "☕ Cà phê", "🏃 Thể thao"].map(
                  (interest, i) => (
                    <span
                      key={i}
                      className="bg-pink-100 text-pink-700 px-3 py-1 rounded-full text-xs"
                    >
                      {interest}
                    </span>
                  )
                )}
              </div>
            </div>

            <div>
              <h3 className="font-semibold mb-2">Về tôi</h3>
              <p className="text-slate-600 text-sm">
                Yêu thích công nghệ, du lịch và khám phá những điều mới mẻ. Tìm
                kiếm một người bạn đồng hành chân thành...
              </p>
            </div>
          </div>
        </div>
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
