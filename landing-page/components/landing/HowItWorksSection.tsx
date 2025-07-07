"use client";

import React from "react";
import { UserPlus, Heart, MessageCircle, Sparkles } from "lucide-react";

interface HowItWorksSectionProps {
  t: any;
}

export function HowItWorksSection({ t }: HowItWorksSectionProps) {
  const steps = [
    {
      icon: UserPlus,
      title: t.step1Title,
      desc: t.step1Desc,
      number: "1",
      gradient: "from-pink-500 to-rose-500",
      bgGradient:
        "from-pink-50 to-rose-50 dark:from-pink-900/10 dark:to-rose-900/10",
    },
    {
      icon: Heart,
      title: t.step2Title,
      desc: t.step2Desc,
      number: "2",
      gradient: "from-purple-500 to-pink-500",
      bgGradient:
        "from-purple-50 to-pink-50 dark:from-purple-900/10 dark:to-pink-900/10",
    },
    {
      icon: MessageCircle,
      title: t.step3Title,
      desc: t.step3Desc,
      number: "3",
      gradient: "from-rose-500 to-pink-500",
      bgGradient:
        "from-rose-50 to-pink-50 dark:from-rose-900/10 dark:to-pink-900/10",
    },
  ];

  return (
    <section id="how-it-works" className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900"></div>

      {/* Decorative elements */}
      <div className="absolute top-20 left-20 w-32 h-32 bg-gradient-to-r from-pink-200/30 to-purple-200/30 rounded-full blur-3xl"></div>
      <div className="absolute bottom-20 right-20 w-40 h-40 bg-gradient-to-r from-purple-200/30 to-rose-200/30 rounded-full blur-3xl"></div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-100 to-purple-100 dark:from-pink-900/20 dark:to-purple-900/20 text-pink-600 dark:text-pink-400 px-4 py-2 rounded-full text-sm font-semibold mb-4">
            <Sparkles className="w-4 h-4" />
            {t.howItWorksTag}
          </div>
          <h2 className="text-4xl lg:text-5xl font-bold bg-gradient-to-r from-slate-800 to-slate-600 dark:from-slate-100 dark:to-slate-300 bg-clip-text text-transparent mb-6">
            {t.howItWorksTitle}
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300 max-w-3xl mx-auto leading-relaxed">
            {t.howItWorksSubtitle}
          </p>
        </div>

        <div className="relative">
          {/* Connection line */}
          <div className="hidden md:block absolute top-12 left-0 w-full h-1 bg-gradient-to-r from-pink-300 via-purple-300 to-rose-300 rounded-full"></div>

          <div className="grid md:grid-cols-3 gap-16 relative">
            {steps.map((step, index) => (
              <div
                key={index}
                className="text-center scroll-animation opacity-0 translate-y-10"
                style={{ animationDelay: `${index * 200}ms` }}
              >
                <div className="group relative mb-6">
                  <div className="bg-white dark:bg-slate-800 w-24 h-24 rounded-full mx-auto flex items-center justify-center shadow-2xl relative z-10 group-hover:scale-110 transition-transform duration-300">
                    <span
                      className={`absolute -top-3 -right-3 bg-gradient-to-r ${step.gradient} text-white w-10 h-10 rounded-full flex items-center justify-center font-bold text-xl border-4 border-white dark:border-slate-800 shadow-lg`}
                    >
                      {step.number}
                    </span>
                    <step.icon className="w-12 h-12 text-pink-500 dark:text-pink-400 group-hover:scale-110 transition-transform duration-300" />
                  </div>

                  {/* Hover effect background */}
                  <div
                    className={`absolute inset-0 bg-gradient-to-br ${step.bgGradient} rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500 transform scale-150`}
                  ></div>
                </div>

                <h3 className="text-2xl font-bold mb-4 text-slate-800 dark:text-slate-100">
                  {step.title}
                </h3>
                <p className="text-slate-600 dark:text-slate-300 leading-relaxed max-w-sm mx-auto">
                  {step.desc}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Call to action */}
        <div className="text-center mt-16">
          <a
            href="#download"
            className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-rose-500 text-white px-8 py-4 rounded-full font-bold text-lg transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl"
          >
            <Heart className="w-5 h-5" />
            {t.startToday}
          </a>
        </div>
      </div>
    </section>
  );
}
