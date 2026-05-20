'use client'

import { useLanguage } from '@/lib/language-context'

export function FooterBar() {
  const { t } = useLanguage()

  return (
    <footer className="border-t border-border bg-background text-center text-sm text-muted-foreground py-4">
      <p>&copy; {new Date().getFullYear()} {t('footer.allRightsReserved')}</p>
    </footer>
  )
}
