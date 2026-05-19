'use client'

import { createContext, useContext, useState, useEffect, type ReactNode, useCallback } from 'react'
import enTranslations from '../locales/en.json'
import amTranslations from '../locales/am.json'

export type Language = 'en' | 'am'

const translations: Record<Language, any> = {
  en: enTranslations,
  am: amTranslations,
}

interface LanguageContextType {
  language: Language
  setLanguage: (lang: Language) => void
  t: (key: string) => string
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

const LANGUAGE_STORAGE_KEY = 'foresite_pref_lang'

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<Language>('en')
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    const stored = localStorage.getItem(LANGUAGE_STORAGE_KEY) as Language | null
    if (stored === 'en' || stored === 'am') {
      setLanguageState(stored)
    }
    setMounted(true)
  }, [])

  const setLanguage = useCallback((lang: Language) => {
    setLanguageState(lang)
    try {
      localStorage.setItem(LANGUAGE_STORAGE_KEY, lang)
    } catch (e) {
      console.error('Failed to save language preference', e)
    }
  }, [])

  const t = useCallback((key: string): string => {
    const keys = key.split('.')
    let curr: any = translations[language]

    for (const k of keys) {
      if (curr && typeof curr === 'object' && k in curr) {
        curr = curr[k]
      } else {
        // Fallback to English if key missing in Amharic
        if (language !== 'en') {
          let enCurr: any = translations['en']
          for (const ek of keys) {
            if (enCurr && typeof enCurr === 'object' && ek in enCurr) {
              enCurr = enCurr[ek]
            } else {
              return key
            }
          }
          if (typeof enCurr === 'string') return enCurr
        }
        return key
      }
    }

    if (typeof curr === 'string') {
      return curr
    }
    return key
  }, [language])

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider')
  }
  return context
}
