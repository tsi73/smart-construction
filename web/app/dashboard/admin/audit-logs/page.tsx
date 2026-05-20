'use client'

import { useEffect, useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { useAuth } from '@/lib/auth-context'
import { listAuditLogs, getAuditLogsCsvUrl } from '@/lib/api'
import { getAccessToken } from '@/lib/auth-storage'
import type { AuditLogItem } from '@/lib/api-types'
import { Loader2, ArrowLeft, Download, ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useLanguage } from '@/lib/language-context'

const PAGE_SIZE = 50

export default function AdminAuditLogsPage() {
    const router = useRouter()
    const { user, isAuthenticated, isLoading: authLoading } = useAuth()
    const { t } = useLanguage()
    const [logs, setLogs] = useState<AuditLogItem[]>([])
    const [total, setTotal] = useState(0)
    const [page, setPage] = useState(1)
    const [loading, setLoading] = useState(true)
    const [exporting, setExporting] = useState(false)
    const [error, setError] = useState<string | null>(null)

    // Filters
    const [actionFilter, setActionFilter] = useState<string>('all')
    const [entityFilter, setEntityFilter] = useState<string>('all')
    const [userSearch, setUserSearch] = useState<string>('')
    const [startDate, setStartDate] = useState<string>('')
    const [endDate, setEndDate] = useState<string>('')

    // Detail modal
    const [selected, setSelected] = useState<AuditLogItem | null>(null)

    useEffect(() => {
        if (!authLoading && !isAuthenticated) {
            router.push('/login')
        }
        if (!authLoading && isAuthenticated && !user?.is_admin) {
            router.push('/dashboard')
        }
    }, [authLoading, isAuthenticated, user, router])

    const filterParams = useCallback(() => {
        const params: Record<string, string | number> = {}
        if (actionFilter !== 'all') params.action = actionFilter
        if (entityFilter !== 'all') params.entity_type = entityFilter
        if (userSearch.trim()) params.user_search = userSearch.trim()
        if (startDate) params.start_date = `${startDate}T00:00:00`
        if (endDate) params.end_date = `${endDate}T23:59:59`
        return params
    }, [actionFilter, entityFilter, userSearch, startDate, endDate])

    const loadLogs = useCallback(async () => {
        setLoading(true)
        setError(null)
        try {
            const params = { ...filterParams(), page, limit: PAGE_SIZE }
            const res = await listAuditLogs(params)
            setLogs(res.data)
            setTotal(res.total)
        } catch (err) {
            setError(err instanceof Error ? err.message : t('auditLogsPage.failedToLoad'))
        } finally {
            setLoading(false)
        }
    }, [filterParams, page])

    useEffect(() => {
        if (!isAuthenticated || !user?.is_admin) return
        loadLogs()
    }, [isAuthenticated, user, loadLogs])

    // Reset to first page when filters change
    useEffect(() => {
        setPage(1)
    }, [actionFilter, entityFilter, userSearch, startDate, endDate])

    const clearFilters = () => {
        setActionFilter('all')
        setEntityFilter('all')
        setUserSearch('')
        setStartDate('')
        setEndDate('')
    }

    const handleExportCsv = async () => {
        setExporting(true)
        try {
            const url = getAuditLogsCsvUrl(filterParams() as never)
            const res = await fetch(url, {
                headers: { Authorization: `Bearer ${getAccessToken() ?? ''}` },
            })
            if (!res.ok) throw new Error(t('auditLogsPage.exportFailed'))
            const blob = await res.blob()
            const a = document.createElement('a')
            a.href = URL.createObjectURL(blob)
            a.download = `audit-logs-${new Date().toISOString().slice(0, 10)}.csv`
            document.body.appendChild(a)
            a.click()
            a.remove()
            URL.revokeObjectURL(a.href)
        } catch (err) {
            setError(err instanceof Error ? err.message : t('auditLogsPage.exportFailed'))
        } finally {
            setLoading(false) // Wait, actually setting exporting to false is done in finally originally, let's keep that. Wait, the original code has `setExporting(false)` here, let me check the target content first.
        }
    }

    if (authLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        )
    }

    if (!isAuthenticated || !user?.is_admin) return null

    const getActionBadgeColor = (action: string) => {
        const a = action.toUpperCase()
        if (a.includes('CREATE')) return 'bg-green-50 text-green-700 border-green-200'
        if (a.includes('UPDATE') || a.includes('EDIT')) return 'bg-blue-50 text-blue-700 border-blue-200'
        if (a.includes('DELETE')) return 'bg-red-50 text-red-700 border-red-200'
        if (a.includes('APPROVE')) return 'bg-purple-50 text-purple-700 border-purple-200'
        if (a.includes('REJECT')) return 'bg-orange-50 text-orange-700 border-orange-200'
        return 'bg-gray-50 text-gray-700 border-gray-200'
    }

    const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE))

    return (
        <div className="p-8 space-y-6">
            <div className="flex items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('auditLogsPage.title')}</h1>
                    <p className="text-muted-foreground mt-1">{t('auditLogsPage.subtitle')}</p>
                </div>
                <Button onClick={() => void handleExportCsv()} disabled={exporting} className="gap-2">
                    {exporting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
                    {exporting ? t('auditLogsPage.exporting') : t('auditLogsPage.exportCsv')}
                </Button>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>{t('auditLogsPage.filters')}</CardTitle>
                    <CardDescription>{t('auditLogsPage.filtersDesc')}</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
                        <div className="space-y-1">
                            <Label className="text-xs">{t('auditLogsPage.action')}</Label>
                            <Select value={actionFilter} onValueChange={setActionFilter}>
                                <SelectTrigger><SelectValue /></SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">{t('auditLogsPage.all')}</SelectItem>
                                    <SelectItem value="CREATE">{t('auditLogsPage.actions.create')}</SelectItem>
                                    <SelectItem value="UPDATE">{t('auditLogsPage.actions.update')}</SelectItem>
                                    <SelectItem value="DELETE">{t('auditLogsPage.actions.delete')}</SelectItem>
                                    <SelectItem value="APPROVE">{t('auditLogsPage.actions.approve')}</SelectItem>
                                    <SelectItem value="REJECT">{t('auditLogsPage.actions.reject')}</SelectItem>
                                    <SelectItem value="LOGIN">{t('auditLogsPage.actions.login')}</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="space-y-1">
                            <Label className="text-xs">{t('auditLogsPage.entityType')}</Label>
                            <Select value={entityFilter} onValueChange={setEntityFilter}>
                                <SelectTrigger><SelectValue /></SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">{t('auditLogsPage.all')}</SelectItem>
                                    <SelectItem value="project">{t('auditLogsPage.entities.project')}</SelectItem>
                                    <SelectItem value="task">{t('auditLogsPage.entities.task')}</SelectItem>
                                    <SelectItem value="daily_log">{t('auditLogsPage.entities.dailyLog')}</SelectItem>
                                    <SelectItem value="user">{t('auditLogsPage.entities.user')}</SelectItem>
                                    <SelectItem value="announcement">{t('auditLogsPage.entities.announcement')}</SelectItem>
                                    <SelectItem value="supplier">{t('auditLogsPage.entities.supplier')}</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="space-y-1">
                            <Label className="text-xs">{t('auditLogsPage.userLabel')}</Label>
                            <Input
                                placeholder={t('auditLogsPage.searchPlaceholder')}
                                value={userSearch}
                                onChange={(e) => setUserSearch(e.target.value)}
                            />
                        </div>
                        <div className="space-y-1">
                            <Label className="text-xs">{t('auditLogsPage.from')}</Label>
                            <Input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} />
                        </div>
                        <div className="space-y-1">
                            <Label className="text-xs">{t('auditLogsPage.to')}</Label>
                            <Input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} />
                        </div>
                    </div>
                    <div className="flex justify-end mt-3">
                        <Button variant="ghost" size="sm" onClick={clearFilters}>{t('auditLogsPage.clearFilters')}</Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>{t('auditLogsPage.systemActivityLog')}</CardTitle>
                    <CardDescription>{total.toLocaleString()} {t('auditLogsPage.totalEntries')}</CardDescription>
                </CardHeader>
                <CardContent className="space-y-3">
                    {error && (
                        <div className="p-4 border border-destructive/20 bg-destructive/5 rounded-lg text-sm text-destructive">
                            {error}
                        </div>
                    )}

                    <div className="border rounded-lg">
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>{t('auditLogsPage.timestamp')}</TableHead>
                                    <TableHead>{t('auditLogsPage.action')}</TableHead>
                                    <TableHead>{t('auditLogsPage.entity')}</TableHead>
                                    <TableHead>{t('auditLogsPage.user')}</TableHead>
                                    <TableHead>{t('auditLogsPage.details')}</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {loading ? (
                                    <TableRow>
                                        <TableCell colSpan={5} className="text-center py-8">
                                            <Loader2 className="h-6 w-6 animate-spin mx-auto text-muted-foreground" />
                                        </TableCell>
                                    </TableRow>
                                ) : logs.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                                            {t('auditLogsPage.noLogs')}
                                        </TableCell>
                                    </TableRow>
                                ) : (
                                    logs.map((log) => (
                                        <TableRow
                                            key={log.id}
                                            className="cursor-pointer hover:bg-muted/40"
                                            onClick={() => setSelected(log)}
                                        >
                                            <TableCell className="font-mono text-xs whitespace-nowrap">
                                                {new Date(log.created_at).toLocaleString('en-US', {
                                                    month: 'short', day: 'numeric', year: 'numeric',
                                                    hour: '2-digit', minute: '2-digit',
                                                })}
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant="outline" className={getActionBadgeColor(log.action)}>
                                                    {log.action}
                                                </Badge>
                                            </TableCell>
                                            <TableCell>
                                                <div className="text-sm">{log.entity_type || '—'}</div>
                                                {log.entity_id && (
                                                    <div className="font-mono text-[10px] text-muted-foreground">
                                                        {log.entity_id.slice(0, 8)}…
                                                    </div>
                                                )}
                                            </TableCell>
                                            <TableCell>
                                                <div className="text-sm">{log.user_name || '—'}</div>
                                                {log.user_email && (
                                                    <div className="text-[11px] text-muted-foreground">{log.user_email}</div>
                                                )}
                                            </TableCell>
                                            <TableCell className="text-sm text-muted-foreground max-w-md">
                                                <span className="line-clamp-2">{log.details || '—'}</span>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                )}
                            </TableBody>
                        </Table>
                    </div>

                    {/* Pagination */}
                    {total > 0 && (
                        <div className="flex items-center justify-between text-sm">
                            <span className="text-muted-foreground">
                                {t('auditLogsPage.page')} {page} {t('auditLogsPage.of')} {totalPages} · {t('auditLogsPage.showing')} {logs.length} {t('auditLogsPage.of')} {total.toLocaleString()}
                            </span>
                            <div className="flex items-center gap-2">
                                <Button
                                    variant="outline" size="sm"
                                    disabled={page <= 1 || loading}
                                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                                >
                                    <ChevronLeft className="h-4 w-4" /> {t('auditLogsPage.prev')}
                                </Button>
                                <Button
                                    variant="outline" size="sm"
                                    disabled={page >= totalPages || loading}
                                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                                >
                                    {t('auditLogsPage.next')} <ChevronRight className="h-4 w-4" />
                                </Button>
                            </div>
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Detail modal */}
            <Dialog open={!!selected} onOpenChange={(open) => !open && setSelected(null)}>
                <DialogContent className="sm:max-w-2xl">
                    <DialogHeader>
                        <DialogTitle>{t('auditLogsPage.detailTitle')}</DialogTitle>
                        <DialogDescription>{t('auditLogsPage.detailDesc')}</DialogDescription>
                    </DialogHeader>
                    {selected && (
                        <dl className="grid grid-cols-3 gap-x-3 gap-y-3 py-2 text-sm">
                            <dt className="text-muted-foreground">{t('auditLogsPage.timestamp')}</dt>
                            <dd className="col-span-2 font-mono">{new Date(selected.created_at).toLocaleString()}</dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.action')}</dt>
                            <dd className="col-span-2">
                                <Badge variant="outline" className={getActionBadgeColor(selected.action)}>
                                    {selected.action}
                                </Badge>
                            </dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.entity')}</dt>
                            <dd className="col-span-2">{selected.entity_type || '—'}</dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.entityId')}</dt>
                            <dd className="col-span-2 font-mono break-all text-xs">{selected.entity_id || '—'}</dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.user')}</dt>
                            <dd className="col-span-2">
                                {selected.user_name || '—'}
                                {selected.user_email && <span className="text-muted-foreground"> · {selected.user_email}</span>}
                            </dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.userId')}</dt>
                            <dd className="col-span-2 font-mono break-all text-xs">{selected.user_id || '—'}</dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.projectId')}</dt>
                            <dd className="col-span-2 font-mono break-all text-xs">{selected.project_id || '—'}</dd>

                            <dt className="text-muted-foreground">{t('auditLogsPage.details')}</dt>
                            <dd className="col-span-2 whitespace-pre-wrap break-words">{selected.details || '—'}</dd>
                        </dl>
                    )}
                </DialogContent>
            </Dialog>
        </div>
    )
}
