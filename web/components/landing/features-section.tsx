'use client'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { ClipboardList, Users, BarChart3, Shield, Clock, Zap } from 'lucide-react'
import { useLanguage } from '@/lib/language-context'

export function FeaturesSection() {
  const { t } = useLanguage()

  const features = [
    {
      icon: ClipboardList,
      title: t('features.items.dailyLogsTitle'),
      description: t('features.items.dailyLogsDesc'),
    },
    {
      icon: Users,
      title: t('features.items.roleAccessTitle'),
      description: t('features.items.roleAccessDesc'),
    },
    {
      icon: BarChart3,
      title: t('features.items.analyticsTitle'),
      description: t('features.items.analyticsDesc'),
    },
    {
      icon: Shield,
      title: t('features.items.riskPredictTitle'),
      description: t('features.items.riskPredictDesc'),
    },
    {
      icon: Clock,
      title: t('features.items.weatherTitle'),
      description: t('features.items.weatherDesc'),
    },
    {
      icon: Zap,
      title: t('features.items.notificationsTitle'),
      description: t('features.items.notificationsDesc'),
    },
  ]

  return (
    <section className="py-20 bg-background">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl text-foreground">
            {t('features.title')}
          </h2>
          <p className="mt-4 text-lg text-muted-foreground max-w-2xl mx-auto">
            {t('features.subtitle')}
          </p>
        </div>
        
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <Card key={index} className="border-border hover:border-accent/50 transition-colors">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <feature.icon className="h-6 w-6 text-primary" />
                </div>
                <CardTitle className="text-lg">{feature.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-muted-foreground leading-relaxed">
                  {feature.description}
                </CardDescription>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
