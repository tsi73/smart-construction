'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useAuth } from '@/lib/auth-context'
import {
    getPlatformSummary, getActivitySummary,
    type PlatformSummary, type ActivitySeriesPoint,
} from '@/lib/api'
import { useCurrency } from '@/lib/currency-context'
import { Loader2, Users, Building2, ListTodo, ClipboardList } from 'lucide-react'
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '@/components/ui/chart'
import { CartesianGrid, Line, LineChart, XAxis, YAxis, Legend } from 'recharts'
import { useLanguage } from '@/lib/language-context'

export default function AdminReportsPage() {
    const router = useRouter()
    const { user, isAuthenticated, isLoading: authLoading } = useAuth()
    const { formatBudget } = useCurrency()
    const { t } = useLanguage()
    const [summary, setSummary] = useState<PlatformSummary | null>(null)
    const [series, setSeries] = useState<ActivitySeriesPoint[]>([])
    const [days, setDays] = useState<number>(30)
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)

    useEffect(() => {
        if (!authLoading && !isAuthenticated) router.push('/login')
        if (!authLoading && isAuthenticated && !user?.is_admin) router.push('/dashboard')
    }, [authLoading, isAuthenticated, user, router])

    useEffect(() => {
        if (!isAuthenticated || !user?.is_admin) return
        let cancelled = false
        ;(async () => {
            setLoading(true)
            setError(null)
            try {
                const [s, a] = await Promise.all([
                    getPlatformSummary(),
                    getActivitySummary(days),
                ])
                if (cancelled) return
                setSummary(s)
                setSeries(a.series)
            } catch (e) {
                if (!cancelled) setError(e instanceof Error ? e.message : t('reportsPage.failedToLoad'))
            } finally {
                if (!cancelled) setLoading(false)
            }
        })()
        return () => { cancelled = true }
    }, [isAuthenticated, user, days])

    if (authLoading || (loading && !summary)) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        )
    }
    if (!isAuthenticated || !user?.is_admin) return null

    return (
        <div className="p-8 space-y-6">
            <div className="flex items-end justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('reportsPage.title')}</h1>
                    <p className="text-muted-foreground mt-1">{t('reportsPage.subtitle')}</p>
                </div>
                <Select value={String(days)} onValueChange={(v) => setDays(Number(v))}>
                    <SelectTrigger className="w-[160px]"><SelectValue /></SelectTrigger>
                    <SelectContent>
                        <SelectItem value="7">{t('reportsPage.last7Days')}</SelectItem>
                        <SelectItem value="30">{t('reportsPage.last30Days')}</SelectItem>
                        <SelectItem value="90">{t('reportsPage.last90Days')}</SelectItem>
                        <SelectItem value="180">{t('reportsPage.last180Days')}</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            {error && (
                <div className="p-4 border border-destructive/20 bg-destructive/5 rounded-lg text-sm text-destructive">
                    {error}
                </div>
            )}

            {summary && (
                <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                    <SummaryCard
                        icon={<Users className="h-4 w-4 text-muted-foreground" />}
                        label={t('reportsPage.usersLabel')}
                        primary={`${summary.users.total}`}
                        sub={t('reportsPage.usersSub').replace('{active}', String(summary.users.active)).replace('{admins}', String(summary.users.admins))}
                    />
                    <SummaryCard
                        icon={<Building2 className="h-4 w-4 text-muted-foreground" />}
                        label={t('reportsPage.projectsLabel')}
                        primary={`${summary.projects.total}`}
                        sub={Object.entries(summary.projects.by_status)
                            .map(([k, v]) => `${v} ${t('reportsPage.projectStatus.' + k) || k.replace(/_/g, ' ')}`).join(' · ')}
                    />
                    <SummaryCard
                        icon={<ListTodo className="h-4 w-4 text-muted-foreground" />}
                        label={t('reportsPage.tasksLabel')}
                        primary={`${summary.tasks.total}`}
                        sub={t('reportsPage.tasksSub').replace('{completed}', String(summary.tasks.completed))}
                    />
                    <SummaryCard
                        icon={<ClipboardList className="h-4 w-4 text-muted-foreground" />}
                        label={t('reportsPage.dailyLogsLabel')}
                        primary={`${summary.daily_logs.total}`}
                        sub={t('reportsPage.dailyLogsSub').replace('{approved}', String(summary.daily_logs.pm_approved))}
                    />
                </div>
            )}

            {summary && (
                <Card>
                    <CardHeader>
                        <CardTitle>{t('reportsPage.budgetTitle')}</CardTitle>
                        <CardDescription>{t('reportsPage.budgetDesc')}</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="grid gap-3 sm:grid-cols-3">
                            <div className="rounded-lg border bg-muted/30 p-4">
                                <p className="text-xs uppercase text-muted-foreground">{t('reportsPage.totalBudget')}</p>
                                <p className="mt-1 text-2xl font-bold">{formatBudget(summary.projects.total_budget)}</p>
                            </div>
                            <div className="rounded-lg border bg-muted/30 p-4">
                                <p className="text-xs uppercase text-muted-foreground">{t('reportsPage.spent')}</p>
                                <p className="mt-1 text-2xl font-bold text-amber-700">{formatBudget(summary.projects.total_spent)}</p>
                            </div>
                            <div className="rounded-lg border bg-muted/30 p-4">
                                <p className="text-xs uppercase text-muted-foreground">{t('reportsPage.remaining')}</p>
                                <p className="mt-1 text-2xl font-bold text-emerald-700">{formatBudget(summary.projects.remaining)}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            )}

            <Card>
                <CardHeader>
                    <CardTitle>{t('reportsPage.activityTitle')}</CardTitle>
                    <CardDescription>{t('reportsPage.activityDesc')}</CardDescription>
                </CardHeader>
                <CardContent>
                    <ChartContainer
                        config={{
                            signups: { label: t('reportsPage.signups'), color: '#10b981' },
                            logins: { label: t('reportsPage.activeUsers'), color: '#3b82f6' },
                            log_approvals: { label: t('reportsPage.logApprovals'), color: '#a855f7' },
                            audit_events: { label: t('reportsPage.auditEvents'), color: '#f59e0b' },
                        }}
                        className="h-72 w-full"
                    >
                        <LineChart data={series} margin={{ left: 8, right: 12, top: 10 }}>
                            <CartesianGrid vertical={false} strokeDasharray="3 3" />
                            <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                            <YAxis tick={{ fontSize: 10 }} allowDecimals={false} />
                            <ChartTooltip content={<ChartTooltipContent indicator="line" />} />
                            <Legend />
                            <Line type="monotone" dataKey="signups" stroke="#10b981" strokeWidth={2} dot={false} />
                            <Line type="monotone" dataKey="logins" stroke="#3b82f6" strokeWidth={2} dot={false} />
                            <Line type="monotone" dataKey="log_approvals" stroke="#a855f7" strokeWidth={2} dot={false} />
                            <Line type="monotone" dataKey="audit_events" stroke="#f59e0b" strokeWidth={2} dot={false} />
                        </LineChart>
                    </ChartContainer>
                </CardContent>
            </Card>

        </div>
    )
}

function SummaryCard({ icon, label, primary, sub }: {
    icon: React.ReactNode; label: string; primary: string; sub: string;
}) {
    return (
        <Card>
            <CardContent className="p-4">
                <div className="flex items-center justify-between mb-2">
                    <span className="text-xs uppercase tracking-wide text-muted-foreground">{label}</span>
                    {icon}
                </div>
                <p className="text-3xl font-bold">{primary}</p>
                <p className="text-xs text-muted-foreground mt-1 line-clamp-2">{sub}</p>
            </CardContent>
        </Card>
    )
}
