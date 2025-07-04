"use client";

import React from "react";
import { Quote, Star, Heart } from "lucide-react";

interface TestimonialsSectionProps {
  t: any;
}

export function TestimonialsSection({ t }: TestimonialsSectionProps) {
  const testimonials = [
    {
      quote: t.testimonial1Quote,
      name: t.testimonial1Name,
      status: t.testimonial1Status,
      avatar: "MA",
      rating: 5,
      gradient: "from-pink-400 to-rose-400",
    },
    {
      quote: t.testimonial2Quote,
      name: t.testimonial2Name,
      status: t.testimonial2Status,
      avatar: "LC",
      rating: 5,
      gradient: "from-purple-400 to-indigo-400",
    },
    {
      quote: t.testimonial3Quote,
      name: t.testimonial3Name,
      status: t.testimonial3Status,
      avatar: "QB",
      rating: 5,
      gradient: "from-rose-400 to-pink-400",
    },
  ];

  return (
    <section id="testimonials" className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-white via-pink-50/30 to-purple-50/30 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900"></div>

      {/* Decorative elements */}
      <div className="absolute top-10 left-20 w-24 h-24 bg-gradient-to-r from-pink-200/40 to-rose-200/40 rounded-full blur-2xl"></div>
      <div className="absolute bottom-20 right-20 w-32 h-32 bg-gradient-to-r from-purple-200/40 to-pink-200/40 rounded-full blur-3xl"></div>

      {/* Floating hearts */}
      <div className="absolute top-32 right-1/4 text-pink-300 dark:text-pink-600 animate-pulse">
        <Heart className="w-6 h-6 fill-current" />
      </div>
      <div className="absolute bottom-40 left-1/4 text-rose-300 dark:text-rose-600 animate-pulse delay-1000">
        <Heart className="w-4 h-4 fill-current" />
      </div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-100 to-purple-100 dark:from-pink-900/20 dark:to-purple-900/20 text-pink-600 dark:text-pink-400 px-4 py-2 rounded-full text-sm font-semibold mb-4">
            <Heart className="w-4 h-4" />
            {t.testimonialsTag}
          </div>
          <h2 className="text-4xl lg:text-5xl font-bold bg-gradient-to-r from-slate-800 to-slate-600 dark:from-slate-100 dark:to-slate-300 bg-clip-text text-transparent mb-6">
            {t.testimonialsTitle}
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300 max-w-3xl mx-auto leading-relaxed">
            {t.testimonialsSubtitle}
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="group relative bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm p-8 rounded-3xl transition-all duration-500 hover:-translate-y-3 hover:shadow-2xl scroll-animation opacity-0 translate-y-10 border border-slate-200/50 dark:border-slate-700/50"
              style={{ animationDelay: `${index * 200}ms` }}
            >
              {/* Quote icon with gradient background */}
              <div className="absolute -top-4 -left-4 w-8 h-8 bg-gradient-to-r from-pink-500 to-rose-500 rounded-full flex items-center justify-center shadow-lg">
                <Quote className="w-4 h-4 text-white" />
              </div>

              {/* Rating stars */}
              <div className="flex mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star
                    key={i}
                    className="w-4 h-4 text-yellow-400 fill-current"
                  />
                ))}
              </div>

              <p className="text-slate-700 dark:text-slate-300 mb-6 leading-relaxed italic">
                "{testimonial.quote}"
              </p>

              <div className="flex items-center">
                <div
                  className={`w-12 h-12 bg-gradient-to-r ${testimonial.gradient} rounded-full flex items-center justify-center text-white font-bold mr-4 shadow-lg group-hover:scale-110 transition-transform duration-300`}
                >
                  {testimonial.avatar}
                </div>
                <div>
                  <p className="font-bold text-slate-800 dark:text-slate-100">
                    {testimonial.name}
                  </p>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    {testimonial.status}
                  </p>
                </div>
              </div>

              {/* Hover effect overlay */}
              <div className="absolute inset-0 bg-gradient-to-br from-pink-50/50 to-purple-50/50 dark:from-pink-900/10 dark:to-purple-900/10 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            </div>
          ))}
        </div>

        {/* Trust indicators */}
        <div className="mt-16 text-center">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 max-w-2xl mx-auto">
            <div className="text-center">
              <div className="text-2xl font-bold text-pink-500 dark:text-pink-400">
                98%
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {t.satisfactionRate}
              </div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-rose-500 dark:text-rose-400">
                4.8/5
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {t.ratingLabel}
              </div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-purple-500 dark:text-purple-400">
                15K+
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {t.successfulCouples}
              </div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-indigo-500 dark:text-indigo-400">
                24/7
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                {t.customerSupport}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
