"use client";

import React, { useState, useEffect } from "react";
import {
  ChevronLeft,
  ChevronRight,
  Heart,
  MessageCircle,
  Camera,
  Users,
  Star,
  Shield,
} from "lucide-react";

interface AppScreenshotsProps {
  t: any;
}

export function AppScreenshots({ t }: AppScreenshotsProps) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const screenshots = [
    {
      src: "/app-screenshots/screenshot1.png",
      title: t.screenshot1Title || "Beautiful Profiles",
      description:
        t.screenshot1Desc ||
        "Create your stunning profile with multiple photos and personal details to attract your perfect match.",
      icon: <Users className="w-6 h-6" />,
      color: "from-pink-500 to-rose-500",
    },
    {
      src: "/app-screenshots/screenshot2.png",
      title: t.screenshot2Title || "Smart Matching",
      description:
        t.screenshot2Desc ||
        "Our advanced algorithm finds compatible matches based on your preferences and interests.",
      icon: <Heart className="w-6 h-6" />,
      color: "from-purple-500 to-indigo-500",
    },
    {
      src: "/app-screenshots/screenshot3.png",
      title: t.screenshot3Title || "Instant Messaging",
      description:
        t.screenshot3Desc ||
        "Chat with your matches in real-time with our secure and fun messaging system.",
      icon: <MessageCircle className="w-6 h-6" />,
      color: "from-blue-500 to-cyan-500",
    },
    {
      src: "/app-screenshots/screenshot4.png",
      title: t.screenshot4Title || "Photo Sharing",
      description:
        t.screenshot4Desc ||
        "Share moments and memories with high-quality photo sharing features.",
      icon: <Camera className="w-6 h-6" />,
      color: "from-emerald-500 to-teal-500",
    },
    {
      src: "/app-screenshots/screenshot5.png",
      title: t.screenshot5Title || "Premium Features",
      description:
        t.screenshot5Desc ||
        "Unlock exclusive features like unlimited likes, super likes, and advanced filters.",
      icon: <Star className="w-6 h-6" />,
      color: "from-amber-500 to-orange-500",
    },
    {
      src: "/app-screenshots/screenshot6.png",
      title: t.screenshot6Title || "Safe & Secure",
      description:
        t.screenshot6Desc ||
        "Your privacy and safety are our top priority with advanced verification and security features.",
      icon: <Shield className="w-6 h-6" />,
      color: "from-red-500 to-pink-500",
    },
  ];

  const nextSlide = () => {
    setCurrentSlide((prev) => (prev + 1) % screenshots.length);
  };

  const prevSlide = () => {
    setCurrentSlide(
      (prev) => (prev - 1 + screenshots.length) % screenshots.length
    );
  };

  const goToSlide = (index: number) => {
    setCurrentSlide(index);
  };

  // Auto-play slideshow
  useEffect(() => {
    const interval = setInterval(nextSlide, 5000); // Auto-advance every 5 seconds
    return () => clearInterval(interval);
  }, []);

  return (
    <section className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-white to-purple-50/30 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900"></div>

      <div className="max-w-7xl mx-auto px-6 relative">
        {/* Section Header */}
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-pink-600 to-purple-600 bg-clip-text text-transparent mb-4">
            {t.appScreenshotsTitle || "Experience Amoura"}
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            {t.appScreenshotsSubtitle ||
              "Discover the beautiful interface and powerful features that make finding love effortless"}
          </p>
        </div>

        <div className="relative">
          {/* Navigation Buttons - Outside */}
          <button
            onClick={prevSlide}
            className="absolute left-4 top-1/2 transform -translate-y-1/2 z-10 flex items-center justify-center w-14 h-14 rounded-full bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-700 transition-all duration-300 shadow-lg border border-slate-200 dark:border-slate-600 hover:scale-110"
            aria-label="Previous screenshot"
          >
            <ChevronLeft className="w-6 h-6 text-slate-700 dark:text-slate-300" />
          </button>

          <button
            onClick={nextSlide}
            className="absolute right-4 top-1/2 transform -translate-y-1/2 z-10 flex items-center justify-center w-14 h-14 rounded-full bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-700 transition-all duration-300 shadow-lg border border-slate-200 dark:border-slate-600 hover:scale-110"
            aria-label="Next screenshot"
          >
            <ChevronRight className="w-6 h-6 text-slate-700 dark:text-slate-300" />
          </button>

          {/* Main Slideshow Container */}
          <div className="relative bg-white dark:bg-slate-800 rounded-3xl shadow-2xl p-8 md:p-12 mx-12">
            <div className="grid md:grid-cols-2 gap-8 items-center">
              {/* Screenshot Display */}
              <div className="relative order-2 md:order-1">
                <div className="relative mx-auto max-w-sm">
                  {/* Phone Frame */}
                  <div className="relative bg-gradient-to-br from-slate-800 to-slate-900 rounded-[3rem] p-3 shadow-2xl">
                    <div className="bg-black rounded-[2.5rem] p-1">
                      <div className="relative bg-white rounded-[2rem] overflow-hidden aspect-[9/19.5]">
                        {/* Screenshot */}
                        <img
                          src={screenshots[currentSlide].src}
                          alt={screenshots[currentSlide].title}
                          className="w-full h-full object-cover transition-all duration-500"
                          onError={(e) => {
                            // Fallback to placeholder if image fails to load
                            e.currentTarget.src = "/placeholder.jpg";
                          }}
                        />

                        {/* Overlay gradient for better text readability */}
                        <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent"></div>
                      </div>
                    </div>

                    {/* Phone details */}
                    <div className="absolute top-6 left-1/2 transform -translate-x-1/2 w-20 h-1 bg-slate-600 rounded-full"></div>
                    <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 w-12 h-1 bg-slate-600 rounded-full"></div>
                  </div>
                </div>
              </div>

              {/* Content */}
              <div className="space-y-6 order-1 md:order-2">
                <div
                  className={`inline-flex items-center space-x-3 px-4 py-2 rounded-full bg-gradient-to-r ${screenshots[currentSlide].color} text-white`}
                >
                  {screenshots[currentSlide].icon}
                  <span className="font-medium">
                    Feature {currentSlide + 1} of {screenshots.length}
                  </span>
                </div>

                <h3 className="text-2xl md:text-3xl font-bold text-foreground">
                  {screenshots[currentSlide].title}
                </h3>

                <p className="text-lg text-muted-foreground leading-relaxed">
                  {screenshots[currentSlide].description}
                </p>
              </div>
            </div>

            {/* Slide Indicators */}
            <div className="flex justify-center space-x-2 mt-8">
              {screenshots.map((_, index) => (
                <button
                  key={index}
                  onClick={() => goToSlide(index)}
                  className={`w-3 h-3 rounded-full transition-all duration-300 ${
                    index === currentSlide
                      ? "bg-gradient-to-r from-pink-500 to-purple-500 scale-110"
                      : "bg-slate-300 dark:bg-slate-600 hover:bg-slate-400 dark:hover:bg-slate-500"
                  }`}
                  aria-label={`Go to screenshot ${index + 1}`}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Feature Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mt-12">
          {screenshots.map((screenshot, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className={`p-4 rounded-xl transition-all duration-300 ${
                index === currentSlide
                  ? "bg-gradient-to-r from-pink-500 to-purple-500 text-white scale-105 shadow-lg"
                  : "bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700"
              }`}
            >
              <div className="flex flex-col items-center space-y-2">
                <div
                  className={`${
                    index === currentSlide ? "text-white" : "text-pink-500"
                  }`}
                >
                  {screenshot.icon}
                </div>
                <span className="text-sm font-medium text-center">
                  {screenshot.title}
                </span>
              </div>
            </button>
          ))}
        </div>
      </div>
    </section>
  );
}
