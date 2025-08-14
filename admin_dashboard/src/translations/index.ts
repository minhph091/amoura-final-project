// Central export for all translations
import { en } from './en';
import { vi } from './vi';

export type Language = 'en' | 'vi';

export type TranslationKeys = typeof en;

export const translations = {
  en,
  vi,
} as const;

export { en, vi };