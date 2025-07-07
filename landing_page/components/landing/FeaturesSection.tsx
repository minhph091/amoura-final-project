"use client";

import React from "react";
import { Sparkles, Shield, MessageSquareHeart, Lock } from "lucide-react";

interface FeaturesSectionProps {
  t: any;
}

export function FeaturesSection({ t }: FeaturesSectionProps) {
  const features = [
    {
      icon: Sparkles,
      title: t.feature1Title,
      desc: t.feature1Desc,
      gradient: "from-pink-500 to-rose-500",
      bgGradient:
        "from-pink-50 to-rose-50 dark:from-pink-900/10 dark:to-rose-900/10",
    },
    {
      icon: Shield,
      title: t.feature2Title,
      desc: t.feature2Desc,
      gradient: "from-purple-500 to-indigo-500",
      bgGradient:
        "from-purple-50 to-indigo-50 dark:from-purple-900/10 dark:to-indigo-900/10",
    },
    {
      icon: MessageSquareHeart,
      title: t.feature3Title,
      desc: t.feature3Desc,
      gradient: "from-rose-500 to-pink-500",
      bgGradient:
        "from-rose-50 to-pink-50 dark:from-rose-900/10 dark:to-pink-900/10",
    },
    {
      icon: Lock,
      title: t.feature4Title,
      desc: t.feature4Desc,
      gradient: "from-indigo-500 to-purple-500",
      bgGradient:
        "from-indigo-50 to-purple-50 dark:from-indigo-900/10 dark:to-purple-900/10",
    },
  ];

  return (
    <section id="features" className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-white via-slate-50/50 to-white dark:from-slate-900 dark:via-slate-800/50 dark:to-slate-900"></div>

      {/* Decorative elements */}
      <div className="absolute top-20 left-10 w-32 h-32 bg-gradient-to-r from-pink-200/30 to-purple-200/30 rounded-full blur-3xl"></div>
      <div className="absolute bottom-20 right-10 w-40 h-40 bg-gradient-to-r from-rose-200/30 to-pink-200/30 rounded-full blur-3xl"></div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-100 to-purple-100 dark:from-pink-900/20 dark:to-purple-900/20 text-pink-600 dark:text-pink-400 px-4 py-2 rounded-full text-sm font-semibold mb-4">
            <Sparkles className="w-4 h-4" />
            {t.featuresTag}
          </div>
          <h2 className="text-4xl lg:text-5xl font-bold bg-gradient-to-r from-slate-800 to-slate-600 dark:from-slate-100 dark:to-slate-300 bg-clip-text text-transparent mb-6">
            {t.featuresTitle}
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300 max-w-3xl mx-auto leading-relaxed">
            {t.featuresSubtitle}
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group relative bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm p-8 rounded-3xl text-center transition-all duration-500 hover:-translate-y-3 hover:shadow-2xl scroll-animation opacity-0 translate-y-10 border border-slate-200/50 dark:border-slate-700/50"
              style={{ animationDelay: `${index * 150}ms` }}
            >
              {/* Gradient background on hover */}
              <div
                className={`absolute inset-0 bg-gradient-to-br ${feature.bgGradient} rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
              ></div>

              <div className="relative z-10">
                <div
                  className={`bg-gradient-to-r ${feature.gradient} w-20 h-20 rounded-2xl mx-auto flex items-center justify-center mb-6 shadow-lg group-hover:scale-110 transition-transform duration-300`}
                >
                  <feature.icon className="w-10 h-10 text-white" />
                </div>
                <h3 className="text-xl font-bold mb-4 text-slate-800 dark:text-slate-100 group-hover:text-slate-900 dark:group-hover:text-white transition-colors">
                  {feature.title}
                </h3>
                <p className="text-slate-600 dark:text-slate-300 group-hover:text-slate-700 dark:group-hover:text-slate-200 transition-colors leading-relaxed">
                  {feature.desc}
                </p>
              </div>

              {/* Shine effect */}
              <div className="absolute inset-0 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-1000"></div>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="text-center mt-16">
          <a
            href="#download"
            className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-rose-500 text-white px-8 py-4 rounded-full font-bold text-lg transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl"
          >
            <Sparkles className="w-5 h-5" />
            {t.exploreNow}
          </a>
        </div>
      </div>
    </section>
  );
}
