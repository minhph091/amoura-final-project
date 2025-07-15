"use client";

import React from "react";
import { Users, Heart, Star, Trophy, Globe, Shield } from "lucide-react";

interface StatsSectionProps {
  t: any;
}

export function StatsSection({ t }: StatsSectionProps) {
  const stats = [
    {
      icon: Users,
      number: "2000+",
      label: t.activeUsers,
      gradient: "from-blue-500 to-cyan-500",
    },
    {
      icon: Heart,
      number: "450+",
      label: t.successfulMatches,
      gradient: "from-pink-500 to-rose-500",
    },
    {
      icon: Star,
      number: "4.5/5",
      label: t.averageRating,
      gradient: "from-yellow-500 to-orange-500",
    },
    {
      icon: Trophy,
      number: "85+",
      label: t.marriedCouples,
      gradient: "from-purple-500 to-indigo-500",
    },
    {
      icon: Globe,
      number: "3+",
      label: t.countries,
      gradient: "from-green-500 to-emerald-500",
    },
    {
      icon: Shield,
      number: "98%",
      label: t.safetyRate,
      gradient: "from-red-500 to-pink-500",
    },
  ];

  return (
    <section className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-r from-slate-900 via-purple-900 to-slate-900 dark:from-slate-950 dark:via-purple-950 dark:to-slate-950"></div>

      {/* Animated background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-20 w-32 h-32 bg-gradient-to-r from-pink-500/20 to-purple-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-20 right-20 w-40 h-40 bg-gradient-to-r from-blue-500/20 to-cyan-500/20 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-48 h-48 bg-gradient-to-r from-purple-500/10 to-pink-500/10 rounded-full blur-3xl animate-pulse delay-500"></div>
      </div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <h2 className="text-3xl lg:text-4xl font-bold text-white mb-4">
            {t.statsTitle}
          </h2>
          <p className="text-slate-300 text-lg max-w-2xl mx-auto">
            {t.statsSubtitle}
          </p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-8">
          {stats.map((stat, index) => (
            <div
              key={index}
              className="text-center group"
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className="relative mb-4">
                <div
                  className={`w-16 h-16 mx-auto rounded-2xl bg-gradient-to-r ${stat.gradient} flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300`}
                >
                  <stat.icon className="w-8 h-8 text-white" />
                </div>
                {/* Glow effect */}
                <div
                  className={`absolute inset-0 w-16 h-16 mx-auto rounded-2xl bg-gradient-to-r ${stat.gradient} opacity-0 group-hover:opacity-30 blur-xl transition-opacity duration-300`}
                ></div>
              </div>

              <div className="text-3xl font-bold text-white mb-2 group-hover:scale-105 transition-transform duration-300">
                {stat.number}
              </div>
              <div className="text-slate-300 text-sm font-medium">
                {stat.label}
              </div>
            </div>
          ))}
        </div>

        {/* Bottom section */}
        <div className="mt-16 text-center">
          <div className="inline-flex items-center gap-4 bg-white/10 backdrop-blur-sm rounded-2xl px-8 py-4 border border-white/20">
            <div className="flex -space-x-2">
              {[...Array(5)].map((_, i) => (
                <div
                  key={i}
                  className="w-10 h-10 rounded-full bg-gradient-to-r from-pink-400 to-purple-400 border-2 border-white flex items-center justify-center text-white font-bold text-sm"
                >
                  {String.fromCharCode(65 + i)}
                </div>
              ))}
            </div>
            <div className="text-left">
              <div className="text-white font-bold">{t.joinCommunity}</div>
              <div className="text-slate-300 text-sm">
                {t.thousandsJoinDaily}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
