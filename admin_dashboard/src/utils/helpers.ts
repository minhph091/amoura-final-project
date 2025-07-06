import { cn } from "@/lib/utils";

export function formatDate(date: string | Date): string {
  if (typeof date === "string") {
    // Handle relative dates like "2 hours ago", "3 days ago"
    if (date.includes("ago")) {
      return date;
    }

    // Try to parse as date string
    const parsedDate = new Date(date);
    if (!isNaN(parsedDate.getTime())) {
      return parsedDate.toLocaleDateString();
    }

    return date;
  }

  return date.toLocaleDateString();
}

export function formatNumber(num: number): string {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + "M";
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + "K";
  }
  return num.toString();
}

export function getInitials(name: string): string {
  return name
    .split(" ")
    .map((word) => word.charAt(0))
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

export function capitalizeFirst(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + "...";
}

export function getStatusColor(status: string): string {
  const colors = {
    active: "bg-green-500",
    inactive: "bg-gray-500",
    suspended: "bg-red-500",
    pending: "bg-yellow-500",
    blocked: "bg-red-600",
    disabled: "bg-gray-600",
    resolved: "bg-green-600",
    investigating: "bg-blue-500",
    escalated: "bg-purple-500",
    dismissed: "bg-gray-400",
  };

  return colors[status as keyof typeof colors] || colors.inactive;
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;

  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function generateId(prefix: string = ""): string {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substr(2, 5);
  return `${prefix}${prefix ? "-" : ""}${timestamp}-${randomStr}`;
}
