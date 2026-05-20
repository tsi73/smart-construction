'use client'

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { Building2, ArrowRight } from 'lucide-react'
import { useLanguage } from '@/lib/language-context'

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1'

interface HeroSectionProps {
  onOpenDashboard: () => void
  isAuthenticated: boolean
}

export function HeroSection({ onOpenDashboard, isAuthenticated }: HeroSectionProps) {
  const { t } = useLanguage()
  const [stats, setStats] = useState({ active_projects: 0, team_members: 0 })

  useEffect(() => {
    fetch(`${API_BASE}/landing/stats`)
      .then(r => r.ok ? r.json() : null)
      .then(data => { if (data) setStats(data) })
      .catch(() => {})
  }, [])

  return (
    <section className="relative bg-primary text-primary-foreground">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.4'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        }} />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="grid gap-12 lg:grid-cols-2 lg:gap-8 items-center">
          {/* Left Content */}
          <div className="space-y-8">
            <div className="flex items-center gap-2 text-primary-foreground/80">
              <Building2 className="h-6 w-6" />
              <span className="text-sm font-medium uppercase tracking-wider">{t('hero.tagline')}</span>
            </div>

            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl text-balance">
              {t('hero.title1')}{' '}
              <span className="text-accent">{t('hero.title2')}</span>
            </h1>

            <p className="text-lg text-primary-foreground/80 max-w-xl leading-relaxed">
              {t('hero.subtitle')}
            </p>

            <div className="flex flex-wrap gap-4">
              <Button
                size="lg"
                variant="secondary"
                className="gap-2 font-semibold cursor-pointer"
                onClick={onOpenDashboard}
              >
                {isAuthenticated ? t('nav.openDashboard') : t('hero.getStarted')}
                <ArrowRight className="h-4 w-4" />
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="border-primary-foreground/30 text-primary hover:bg-primary-foreground/10 hover:text-primary-foreground cursor-pointer"
              >
                {t('hero.learnMore')}
              </Button>
            </div>
            
            {/* Stats */}
            <div className="grid grid-cols-2 gap-8 pt-8 border-t border-primary-foreground/20">
              <div>
                <div className="text-3xl font-bold">{stats.active_projects}+</div>
                <div className="text-sm text-primary-foreground/70">{t('hero.activeProjects')}</div>
              </div>
              <div>
                <div className="text-3xl font-bold">{stats.team_members}+</div>
                <div className="text-sm text-primary-foreground/70">{t('hero.teamMembers')}</div>
              </div>
            </div>
          </div>

          {/* Right Image Placeholder */}
          <div className="relative hidden lg:block">
            <div className="aspect-[4/3] rounded-lg bg-primary-foreground/10 overflow-hidden">
              <img
                src="https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&h=600&fit=crop"
                alt="Construction site"
                className="w-full h-full object-cover opacity-80"
              />
            </div>
            {/* Floating Card */}
            <div className="absolute -bottom-6 -left-6 bg-card text-card-foreground rounded-lg shadow-xl p-4 max-w-xs">
              <div className="flex items-center gap-3">
                <div className="h-12 w-12 rounded-full bg-accent/10 flex items-center justify-center">
                  <Building2 className="h-6 w-6 text-accent" />
                </div>
                <div>
                  <div className="font-semibold text-sm">{t('hero.projectProgress')}</div>
                  <div className="text-xs text-muted-foreground">{t('hero.progressSub')}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
