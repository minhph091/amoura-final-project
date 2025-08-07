"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { useTheme } from "next-themes"
import { toast } from "@/hooks/use-toast"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Slider } from "@/components/ui/slider"
import { HexColorPicker } from "react-colorful"

export function ThemeCustomizer() {
  const { theme, setTheme } = useTheme()
  const [isLoading, setIsLoading] = useState(false)
  const [primaryColor, setPrimaryColor] = useState("#e11d48") // Default primary color
  const [mounted, setMounted] = useState(false)

  // Load saved theme color from localStorage on component mount
  useEffect(() => {
    if (typeof window !== "undefined") {
      const savedColor = localStorage.getItem("primaryColor")
      if (savedColor) {
        setPrimaryColor(savedColor)
        applyThemeColor(savedColor)
      }
    }
    setMounted(true)
  }, [])

  // Function to apply theme color to CSS variables
  const applyThemeColor = (color: string) => {
    document.documentElement.style.setProperty("--primary-color", color)

    // Convert hex to hsl for CSS variables
    const r = Number.parseInt(color.slice(1, 3), 16) / 255
    const g = Number.parseInt(color.slice(3, 5), 16) / 255
    const b = Number.parseInt(color.slice(5, 7), 16) / 255

    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    let h = 0,
      s,
      l = (max + min) / 2

    if (max === min) {
      h = s = 0 // achromatic
    } else {
      const d = max - min
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0)
          break
        case g:
          h = (b - r) / d + 2
          break
        case b:
          h = (r - g) / d + 4
          break
      }
      h /= 6
    }

    h = Math.round(h * 360)
    s = Math.round(s * 100)
    l = Math.round(l * 100)

    document.documentElement.style.setProperty("--primary", `${h} ${s}% ${l}%`)
  }

  // Update CSS variables when primary color changes
  useEffect(() => {
    if (mounted) {
      applyThemeColor(primaryColor)
    }
  }, [primaryColor, mounted])

  const handleSave = () => {
    setIsLoading(true)

    // Save to localStorage
    localStorage.setItem("primaryColor", primaryColor)
    localStorage.setItem("theme", theme || "system")

    // Feature not available: No backend endpoint for admin to manage theme customization.
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: "Theme updated",
        description: "Your theme settings have been updated successfully.",
      })
    }, 1000)
  }

  if (!mounted) {
    return null
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Theme Customization</CardTitle>
        <CardDescription>Customize the colors and appearance of your admin dashboard</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <Tabs defaultValue="theme" className="space-y-4">
          <TabsList>
            <TabsTrigger value="theme">Theme Mode</TabsTrigger>
            <TabsTrigger value="colors">Colors</TabsTrigger>
            <TabsTrigger value="fonts">Typography</TabsTrigger>
          </TabsList>

          <TabsContent value="theme" className="space-y-4">
            <h3 className="text-lg font-medium">Theme Mode</h3>

            <RadioGroup defaultValue={theme || "light"} onValueChange={setTheme} className="grid grid-cols-3 gap-4">
              <div>
                <RadioGroupItem value="light" id="light" className="sr-only" />
                <Label
                  htmlFor="light"
                  className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
                >
                  <div className="mb-2 h-24 w-full rounded-md bg-[#fff] shadow-sm"></div>
                  <span className="text-center">Light</span>
                </Label>
              </div>

              <div>
                <RadioGroupItem value="dark" id="dark" className="sr-only" />
                <Label
                  htmlFor="dark"
                  className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
                >
                  <div className="mb-2 h-24 w-full rounded-md bg-[#1e1e1e] shadow-sm"></div>
                  <span className="text-center">Dark</span>
                </Label>
              </div>

              <div>
                <RadioGroupItem value="system" id="system" className="sr-only" />
                <Label
                  htmlFor="system"
                  className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
                >
                  <div className="mb-2 h-24 w-full rounded-md bg-gradient-to-r from-[#fff] to-[#1e1e1e] shadow-sm"></div>
                  <span className="text-center">System</span>
                </Label>
              </div>
            </RadioGroup>
          </TabsContent>

          <TabsContent value="colors" className="space-y-4">
            <h3 className="text-lg font-medium">Primary Color</h3>
            <div className="flex flex-col space-y-4">
              <div className="flex justify-center">
                <HexColorPicker color={primaryColor} onChange={setPrimaryColor} />
              </div>
              <div className="flex items-center gap-2">
                <div
                  className="w-10 h-10 rounded-md border"
                  data-primary-color={primaryColor}
                ></div>
                <style>
                  {`
                    [data-primary-color] {
                      background-color: ${primaryColor};
                    }
                  `}
                </style>
                <input
                  type="text"
                  value={primaryColor}
                  onChange={(e) => setPrimaryColor(e.target.value)}
                  placeholder="Enter hex color"
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                />
              </div>
            </div>

            <div className="mt-6">
              <h3 className="text-lg font-medium mb-4">Preview</h3>
              <div className="space-y-4">
                <div className="flex gap-2">
                  <Button>Primary Button</Button>
                  <Button variant="outline">Outline Button</Button>
                  <Button variant="secondary">Secondary Button</Button>
                </div>
                <div className="h-10 w-full rounded-md bg-primary"></div>
                <div className="h-10 w-full rounded-md bg-primary/20"></div>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="fonts" className="space-y-4">
            <h3 className="text-lg font-medium">Font Size</h3>
            <div className="space-y-4">
              <Label>Base Font Size</Label>
              <Slider
                defaultValue={[16]}
                max={24}
                min={12}
                step={1}
                onValueChange={(value) => {
                  document.documentElement.style.fontSize = `${value[0]}px`
                  localStorage.setItem("fontSize", value[0].toString())
                }}
              />
              <div className="flex justify-between text-xs text-muted-foreground">
                <span>Small</span>
                <span>Medium</span>
                <span>Large</span>
              </div>
            </div>

            <div className="mt-6">
              <h3 className="text-lg font-medium mb-4">Typography Preview</h3>
              <div className="space-y-4">
                <h1 className="text-3xl font-bold">Heading 1</h1>
                <h2 className="text-2xl font-bold">Heading 2</h2>
                <h3 className="text-xl font-bold">Heading 3</h3>
                <p className="text-base">This is a paragraph of text that demonstrates the base font size.</p>
                <p className="text-sm">This is smaller text for less important information.</p>
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button
          variant="cancel"
          onClick={() => {
            setPrimaryColor("#e11d48")
            document.documentElement.style.fontSize = "16px"
            setTheme("system")
            localStorage.removeItem("primaryColor")
            localStorage.removeItem("fontSize")
            localStorage.removeItem("theme")
            applyThemeColor("#e11d48")
            toast({
              title: "Theme reset",
              description: "Your theme settings have been reset to defaults.",
            })
          }}
        >
          Reset to Defaults
        </Button>
        <Button onClick={handleSave} disabled={isLoading}>
          {isLoading ? "Saving..." : "Save Changes"}
        </Button>
      </CardFooter>
    </Card>
  )
}
