import { useState, useEffect } from "react";
import { STORAGE_KEYS } from "../constants/api.constants";

export function useLocalStorage<T>(key: string, initialValue: T) {
  // Get from local storage then parse stored json or return initialValue
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === "undefined") {
      return initialValue;
    }

    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  // Return a wrapped version of useState's setter function that persists the new value to localStorage
  const setValue = (value: T | ((val: T) => T)) => {
    try {
      // Allow value to be a function so we have the same API as useState
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);

      if (typeof window !== "undefined") {
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      }
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue] as const;
}

export function useAuth() {
  const [token, setToken] = useLocalStorage<string | null>(
    STORAGE_KEYS.AUTH_TOKEN,
    null
  );
  const [userData, setUserData] = useLocalStorage<any>(
    STORAGE_KEYS.USER_DATA,
    null
  );

  const isAuthenticated = !!token;

  const login = (authToken: string, user: any) => {
    setToken(authToken);
    setUserData(user);
  };

  const logout = () => {
    setToken(null);
    setUserData(null);
    // Clear other related storage
    localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
  };

  return {
    token,
    user: userData,
    isAuthenticated,
    login,
    logout,
  };
}

export function useSidebar() {
  const [isCollapsed, setIsCollapsed] = useLocalStorage<boolean>(
    STORAGE_KEYS.SIDEBAR_COLLAPSED,
    false
  );

  const toggleCollapse = () => {
    setIsCollapsed(!isCollapsed);
    // Update body attribute for CSS
    document.body.setAttribute(
      "data-sidebar-collapsed",
      (!isCollapsed).toString()
    );
  };

  useEffect(() => {
    // Set initial body attribute
    document.body.setAttribute(
      "data-sidebar-collapsed",
      isCollapsed.toString()
    );
  }, [isCollapsed]);

  return {
    isCollapsed,
    setIsCollapsed,
    toggleCollapse,
  };
}

export function useThemeSettings() {
  const [primaryColor, setPrimaryColor] = useLocalStorage<string>(
    STORAGE_KEYS.PRIMARY_COLOR,
    "#e11d48"
  );
  const [fontSize, setFontSize] = useLocalStorage<number>(
    STORAGE_KEYS.FONT_SIZE,
    16
  );

  const applyThemeColor = (color: string) => {
    // Convert hex to HSL and apply to CSS variables
    const r = parseInt(color.slice(1, 3), 16) / 255;
    const g = parseInt(color.slice(3, 5), 16) / 255;
    const b = parseInt(color.slice(5, 7), 16) / 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h,
      s,
      l = (max + min) / 2;

    if (max === min) {
      h = s = 0; // achromatic
    } else {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
          break;
        default:
          h = 0;
      }
      h /= 6;
    }

    h = Math.round(h * 360);
    s = Math.round(s * 100);
    l = Math.round(l * 100);

    document.documentElement.style.setProperty("--primary", `${h} ${s}% ${l}%`);
  };

  const applyFontSize = (size: number) => {
    document.documentElement.style.fontSize = `${size}px`;
  };

  useEffect(() => {
    applyThemeColor(primaryColor);
  }, [primaryColor]);

  useEffect(() => {
    applyFontSize(fontSize);
  }, [fontSize]);

  return {
    primaryColor,
    fontSize,
    setPrimaryColor: (color: string) => {
      setPrimaryColor(color);
      applyThemeColor(color);
    },
    setFontSize: (size: number) => {
      setFontSize(size);
      applyFontSize(size);
    },
  };
}
