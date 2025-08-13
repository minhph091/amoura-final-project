import React from "react";
import { Heart } from "lucide-react";

export function AmouraLogo({
  size = "default",
}: {
  size?: "small" | "default" | "medium" | "large";
}) {
  const sizeClasses = {
    small: "h-8 w-8",
    default: "h-12 w-12",
    medium: "h-14 w-14",
    large: "h-16 w-16",
  };

  return (
    <div className="flex items-center space-x-3">
      <div className="relative">
        <Heart className={`${sizeClasses[size]} text-rose-500 fill-rose-500`} />
        <div
          className={`absolute -top-1 -right-1 ${
            size === "small"
              ? "w-3 h-3"
              : size === "medium"
              ? "w-4 h-4"
              : size === "large"
              ? "w-5 h-5"
              : "w-4 h-4"
          } bg-gradient-to-r from-pink-400 to-rose-400 rounded-full`}
        />
      </div>
      <div className="font-bold text-gradient bg-gradient-to-r from-rose-500 to-pink-500 bg-clip-text text-transparent">
        <span
          className={`${
            size === "small"
              ? "text-xl"
              : size === "medium"
              ? "text-3xl"
              : size === "large"
              ? "text-4xl"
              : "text-2xl"
          }`}
        >
          Amoura
        </span>
      </div>
    </div>
  );
}
