import type { Metadata } from "next"
import { ThemeCustomizer } from "@/components/settings/theme-customizer"

export const metadata: Metadata = {
  title: "Theme Customization | Amoura Admin",
  description: "Customize the theme of your Amoura admin dashboard",
}

export default function ThemeCustomizationPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Theme Customization</h1>
      <ThemeCustomizer />
    </div>
  )
}
