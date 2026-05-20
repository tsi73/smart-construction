'use client'

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useLanguage, type Language } from '@/lib/language-context'
import { Globe } from 'lucide-react'

export function LanguagePicker() {
  const { language, setLanguage } = useLanguage()

  return (
    <Select value={language} onValueChange={(v) => setLanguage(v as Language)}>
      <SelectTrigger className="h-7 w-[90px] text-xs gap-1.5 px-2">
        <Globe className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="en" className="text-xs">
          English
        </SelectItem>
        <SelectItem value="am" className="text-xs">
          አማርኛ
        </SelectItem>
      </SelectContent>
    </Select>
  )
}
