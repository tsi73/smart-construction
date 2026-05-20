'use client'

import { FooterBar } from '@/components/shared/footer-bar'
import { SiteLogo } from '@/components/site-logo'
import { useLanguage } from '@/lib/language-context'

export function FooterLarge() {
  const { t } = useLanguage()

  return (
    <div className="bg-primary text-primary-foreground">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-4">
          <div className="space-y-4">
            <SiteLogo showText={false} className="justify-start" imageClassName="h-25 w-25" size={80} />
            <p className="text-sm text-primary-foreground/70 max-w-xs">
              {t('footer.description')}
            </p>
          </div>

          <div>
            <h3 className="font-semibold mb-4">{t('footer.product')}</h3>
            <ul className="space-y-2 text-sm text-primary-foreground/70">
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.features')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.pricing')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.integrations')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.api')}</a></li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold mb-4">{t('footer.company')}</h3>
            <ul className="space-y-2 text-sm text-primary-foreground/70">
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.about')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.blog')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.careers')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.contact')}</a></li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold mb-4">{t('footer.legal')}</h3>
            <ul className="space-y-2 text-sm text-primary-foreground/70">
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.privacyPolicy')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.termsOfService')}</a></li>
              <li><a href="#" className="hover:text-primary-foreground transition-colors">{t('footer.cookiePolicy')}</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export function Footer() {
  return (
    <footer>
      <FooterLarge />
      <FooterBar />
    </footer>
  )
}
