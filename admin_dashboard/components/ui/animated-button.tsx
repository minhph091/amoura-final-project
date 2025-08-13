import { cn } from "@/lib/utils";

interface AnimatedButtonProps {
  children: React.ReactNode;
  variant?: 
    | "add" | "create" | "success"
    | "edit" | "update" | "warning" 
    | "delete" | "cancel" | "suspend" | "destructive"
    | "restore" | "activate" | "save" | "view" | "info"
    | "default" | "outline" | "secondary" | "ghost" | "link";
  className?: string;
  pulse?: boolean;
  glow?: boolean;
  ripple?: boolean;
  bounce?: boolean;
  loading?: boolean;
  [key: string]: any;
}

export function getButtonAnimationClasses(variant?: string, pulse?: boolean, glow?: boolean, ripple?: boolean, bounce?: boolean, loading?: boolean) {
  const classes = ["btn-animated"];
  
  if (loading) {
    classes.push("btn-loading");
  }
  
  if (pulse) {
    switch (variant) {
      case "add":
      case "create":
      case "success":
      case "restore":
      case "activate":
        classes.push("btn-success-pulse");
        break;
      case "edit":
      case "update":
      case "warning":
        classes.push("btn-edit-pulse");
        break;
      case "delete":
      case "cancel":
      case "suspend":
      case "destructive":
        classes.push("btn-destructive-pulse");
        break;
    }
  }
  
  if (glow) {
    classes.push("btn-glow");
    switch (variant) {
      case "add":
      case "create":
      case "success":
      case "restore":
      case "activate":
        classes.push("btn-glow-success");
        break;
      case "edit":
      case "update":
      case "warning":
        classes.push("btn-glow-edit");
        break;
      case "delete":
      case "cancel":
      case "suspend":
      case "destructive":
        classes.push("btn-glow-destructive");
        break;
      case "view":
      case "info":
        classes.push("btn-glow-info");
        break;
      case "save":
        classes.push("btn-glow-save");
        break;
    }
  }
  
  if (ripple) {
    classes.push("btn-ripple");
  }
  
  if (bounce) {
    classes.push("btn-bounce");
  }
  
  // Add gradient animation for colorful buttons
  if (["add", "create", "success", "edit", "update", "warning", "delete", "cancel", "suspend", "destructive", "restore", "activate", "save", "view", "info"].includes(variant || "")) {
    classes.push("btn-gradient-animate");
  }
  
  return classes.join(" ");
}

export default function AnimatedButton({ 
  children, 
  variant, 
  className, 
  pulse = false, 
  glow = true, 
  ripple = false, 
  bounce = false, 
  loading = false,
  ...props 
}: AnimatedButtonProps) {
  const animationClasses = getButtonAnimationClasses(variant, pulse, glow, ripple, bounce, loading);
  
  return (
    <button 
      className={cn(animationClasses, className)} 
      {...props}
    >
      {children}
    </button>
  );
}
