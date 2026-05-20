'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
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
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useAuth } from '@/lib/auth-context'
import { listUsers, promoteUser, demoteUser, activateUser, deactivateUser } from '@/lib/api'
import type { UserListItem } from '@/lib/api-types'
import { Loader2, MoreVertical, Search, Shield, ShieldOff, UserCheck, UserX, ArrowLeft, ChevronLeft, ChevronRight, ArrowDown, ArrowUp } from 'lucide-react'
import { useToast } from '@/hooks/use-toast'
import { useLanguage } from '@/lib/language-context'

export default function AdminUsersPage() {
    const router = useRouter()
    const { user, isAuthenticated, isLoading: authLoading } = useAuth()
    const { toast } = useToast()
    const { t } = useLanguage()
    const [users, setUsers] = useState<UserListItem[]>([])
    const [total, setTotal] = useState(0)
    const [page, setPage] = useState(1)
    const [sortBy, setSortBy] = useState<string>('created_at')
    const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc')
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)
    const [searchQuery, setSearchQuery] = useState('')
    const [statusFilter, setStatusFilter] = useState<string>('all')
    const [roleFilter, setRoleFilter] = useState<string>('all')

    const PAGE_SIZE = 25

    useEffect(() => {
        if (!authLoading && !isAuthenticated) {
            router.push('/login')
        }
        if (!authLoading && isAuthenticated && !user?.is_admin) {
            router.push('/dashboard')
        }
    }, [authLoading, isAuthenticated, user, router])

    const loadUsers = async () => {
        setLoading(true)
        setError(null)
        try {
            const params: Record<string, unknown> = {
                page,
                limit: PAGE_SIZE,
                sort_by: sortBy,
                sort_dir: sortDir,
            }
            if (searchQuery) params.search = searchQuery
            if (statusFilter !== 'all') params.is_active = statusFilter === 'active'
            if (roleFilter !== 'all') params.is_admin = roleFilter === 'admin'

            const res = await listUsers(params)
            setUsers(res.data)
            setTotal(res.total)
        } catch (err) {
            setError(err instanceof Error ? err.message : t('userManagementPage.failedToLoad'))
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        if (!isAuthenticated || !user?.is_admin) return
        loadUsers()
    }, [isAuthenticated, user, searchQuery, statusFilter, roleFilter, page, sortBy, sortDir])

    useEffect(() => {
        setPage(1)
    }, [searchQuery, statusFilter, roleFilter])

    const toggleSort = (col: string) => {
        if (sortBy === col) {
            setSortDir(sortDir === 'asc' ? 'desc' : 'asc')
        } else {
            setSortBy(col)
            setSortDir('asc')
        }
    }

    const sortIcon = (col: string) => {
        if (sortBy !== col) return null
        return sortDir === 'asc' ? <ArrowUp className="ml-1 h-3 w-3 inline" /> : <ArrowDown className="ml-1 h-3 w-3 inline" />
    }

    const formatRelative = (iso?: string | null) => {
        if (!iso) return t('userManagementPage.dates.never')
        const diff = Date.now() - new Date(iso).getTime()
        const days = Math.floor(diff / 86_400_000)
        
        const isAmharic = t('userManagementPage.dates.today') === 'ዛሬ'
        
        if (days < 1) return t('userManagementPage.dates.today')
        if (days === 1) return t('userManagementPage.dates.yesterday')
        if (days < 30) {
            return isAmharic 
                ? `ከ ${days} ${t('userManagementPage.dates.days')} ${t('userManagementPage.dates.ago')}`
                : `${days}${t('userManagementPage.dates.days')} ${t('userManagementPage.dates.ago')}`
        }
        if (days < 365) {
            const mos = Math.floor(days / 30)
            return isAmharic 
                ? `ከ ${mos} ${t('userManagementPage.dates.months')} ${t('userManagementPage.dates.ago')}`
                : `${mos}${t('userManagementPage.dates.months')} ${t('userManagementPage.dates.ago')}`
        }
        const yrs = Math.floor(days / 365)
        return isAmharic 
            ? `ከ ${yrs} ${t('userManagementPage.dates.years')} ${t('userManagementPage.dates.ago')}`
            : `${yrs}${t('userManagementPage.dates.years')} ${t('userManagementPage.dates.ago')}`
    }

    const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE))

    const handlePromote = async (userId: string) => {
        try {
            await promoteUser(userId)
            toast({
                title: t('userManagementPage.success'),
                description: t('userManagementPage.promotedSuccess'),
            })
            loadUsers()
        } catch (err) {
            toast({
                title: t('userManagementPage.error'),
                description: err instanceof Error ? err.message : t('userManagementPage.failedToPromote'),
                variant: 'destructive',
            })
        }
    }

    const handleDemote = async (userId: string) => {
        try {
            await demoteUser(userId)
            toast({
                title: t('userManagementPage.success'),
                description: t('userManagementPage.demotedSuccess'),
            })
            loadUsers()
        } catch (err) {
            toast({
                title: t('userManagementPage.error'),
                description: err instanceof Error ? err.message : t('userManagementPage.failedToDemote'),
                variant: 'destructive',
            })
        }
    }

    const handleActivate = async (userId: string) => {
        try {
            await activateUser(userId)
            toast({
                title: t('userManagementPage.success'),
                description: t('userManagementPage.activatedSuccess'),
            })
            loadUsers()
        } catch (err) {
            toast({
                title: t('userManagementPage.error'),
                description: err instanceof Error ? err.message : t('userManagementPage.failedToActivate'),
                variant: 'destructive',
            })
        }
    }

    const handleDeactivate = async (userId: string) => {
        try {
            await deactivateUser(userId)
            toast({
                title: t('userManagementPage.success'),
                description: t('userManagementPage.deactivatedSuccess'),
            })
            loadUsers()
        } catch (err) {
            toast({
                title: t('userManagementPage.error'),
                description: err instanceof Error ? err.message : t('userManagementPage.failedToDeactivate'),
                variant: 'destructive',
            })
        }
    }

    if (authLoading || (loading && users.length === 0)) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        )
    }

    if (!isAuthenticated || !user?.is_admin) return null

    return (
        <div className="p-8 space-y-8">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">{t('userManagementPage.title')}</h1>
                <p className="text-muted-foreground mt-2">{t('userManagementPage.subtitle')}</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>{t('userManagementPage.allUsers')}</CardTitle>
                    <CardDescription>{t('userManagementPage.allUsersDesc')}</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    {/* Filters */}
                    <div className="flex flex-col sm:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder={t('userManagementPage.searchPlaceholder')}
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-9"
                            />
                        </div>
                        <Select value={statusFilter} onValueChange={setStatusFilter}>
                            <SelectTrigger className="w-full sm:w-[180px]">
                                <SelectValue placeholder={t('userManagementPage.status')} />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">{t('userManagementPage.allStatus')}</SelectItem>
                                <SelectItem value="active">{t('userManagementPage.active')}</SelectItem>
                                <SelectItem value="inactive">{t('userManagementPage.inactive')}</SelectItem>
                            </SelectContent>
                        </Select>
                        <Select value={roleFilter} onValueChange={setRoleFilter}>
                            <SelectTrigger className="w-full sm:w-[180px]">
                                <SelectValue placeholder={t('userManagementPage.role')} />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">{t('userManagementPage.allRoles')}</SelectItem>
                                <SelectItem value="admin">{t('userManagementPage.admin')}</SelectItem>
                                <SelectItem value="user">{t('userManagementPage.user')}</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    {error && (
                        <div className="p-4 border border-destructive/20 bg-destructive/5 rounded-lg text-sm text-destructive">
                            {error}
                        </div>
                    )}

                    {/* Users Table */}
                    <div className="border rounded-lg">
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('full_name')}>
                                        {t('userManagementPage.tableName')} {sortIcon('full_name')}
                                    </TableHead>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('email')}>
                                        {t('userManagementPage.tableEmail')} {sortIcon('email')}
                                    </TableHead>
                                    <TableHead>{t('userManagementPage.tablePhone')}</TableHead>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('is_admin')}>
                                        {t('userManagementPage.tableRole')} {sortIcon('is_admin')}
                                    </TableHead>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('is_active')}>
                                        {t('userManagementPage.tableStatus')} {sortIcon('is_active')}
                                    </TableHead>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('created_at')}>
                                        {t('userManagementPage.tableJoined')} {sortIcon('created_at')}
                                    </TableHead>
                                    <TableHead className="cursor-pointer select-none" onClick={() => toggleSort('last_login_at')}>
                                        {t('userManagementPage.tableLastLogin')} {sortIcon('last_login_at')}
                                    </TableHead>
                                    <TableHead className="text-right">{t('userManagementPage.tableActions')}</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {loading ? (
                                    <TableRow>
                                        <TableCell colSpan={8} className="text-center py-8">
                                            <Loader2 className="h-6 w-6 animate-spin mx-auto text-muted-foreground" />
                                        </TableCell>
                                    </TableRow>
                                ) : users.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={8} className="text-center py-8 text-muted-foreground">
                                            {t('userManagementPage.noUsersFound')}
                                        </TableCell>
                                    </TableRow>
                                ) : (
                                    users.map((u) => (
                                        <TableRow key={u.id}>
                                            <TableCell className="font-medium">{u.full_name}</TableCell>
                                            <TableCell>{u.email}</TableCell>
                                            <TableCell>{u.phone_number || '—'}</TableCell>
                                            <TableCell>
                                                {u.is_admin ? (
                                                    <Badge variant="default">{t('userManagementPage.admin')}</Badge>
                                                ) : (
                                                    <Badge variant="secondary">{t('userManagementPage.user')}</Badge>
                                                )}
                                            </TableCell>
                                            <TableCell>
                                                {u.is_active ? (
                                                    <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                                                        {t('userManagementPage.active')}
                                                    </Badge>
                                                ) : (
                                                    <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
                                                        {t('userManagementPage.inactive')}
                                                    </Badge>
                                                )}
                                            </TableCell>
                                            <TableCell className="text-sm text-muted-foreground">
                                                {new Date(u.created_at).toLocaleDateString('en-US', {
                                                    month: 'short',
                                                    day: 'numeric',
                                                    year: 'numeric',
                                                })}
                                            </TableCell>
                                            <TableCell className="text-sm text-muted-foreground">
                                                <span title={u.last_login_at ? new Date(u.last_login_at).toLocaleString() : 'Never logged in'}>
                                                    {formatRelative(u.last_login_at)}
                                                </span>
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <DropdownMenu>
                                                    <DropdownMenuTrigger asChild>
                                                        <Button variant="ghost" size="icon" disabled={u.id === user.id}>
                                                            <MoreVertical className="h-4 w-4" />
                                                        </Button>
                                                    </DropdownMenuTrigger>
                                                    <DropdownMenuContent align="end">
                                                        <DropdownMenuLabel>{t('userManagementPage.tableActions')}</DropdownMenuLabel>
                                                        <DropdownMenuSeparator />
                                                        {u.is_admin ? (
                                                            <DropdownMenuItem onClick={() => handleDemote(u.id)}>
                                                                <ShieldOff className="mr-2 h-4 w-4" />
                                                                {t('userManagementPage.demoteToUser')}
                                                            </DropdownMenuItem>
                                                        ) : (
                                                            <DropdownMenuItem onClick={() => handlePromote(u.id)}>
                                                                <Shield className="mr-2 h-4 w-4" />
                                                                {t('userManagementPage.promoteToAdmin')}
                                                            </DropdownMenuItem>
                                                        )}
                                                        <DropdownMenuSeparator />
                                                        {u.is_active ? (
                                                            <DropdownMenuItem
                                                                onClick={() => handleDeactivate(u.id)}
                                                                className="text-destructive"
                                                            >
                                                                <UserX className="mr-2 h-4 w-4" />
                                                                {t('userManagementPage.deactivate')}
                                                            </DropdownMenuItem>
                                                        ) : (
                                                            <DropdownMenuItem onClick={() => handleActivate(u.id)}>
                                                                <UserCheck className="mr-2 h-4 w-4" />
                                                                {t('userManagementPage.activate')}
                                                            </DropdownMenuItem>
                                                        )}
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                )}
                            </TableBody>
                        </Table>
                    </div>

                    {total > 0 && (
                        <div className="flex items-center justify-between text-sm">
                            <span className="text-muted-foreground">
                                {t('userManagementPage.page')} {page} {t('userManagementPage.of')} {totalPages} · {total.toLocaleString()} {total === 1 ? t('userManagementPage.userSingle') : t('userManagementPage.users')}
                            </span>
                            <div className="flex items-center gap-2">
                                <Button variant="outline" size="sm" disabled={page <= 1 || loading} onClick={() => setPage(p => Math.max(1, p - 1))}>
                                    <ChevronLeft className="h-4 w-4" /> {t('userManagementPage.prev')}
                                </Button>
                                <Button variant="outline" size="sm" disabled={page >= totalPages || loading} onClick={() => setPage(p => Math.min(totalPages, p + 1))}>
                                    {t('userManagementPage.next')} <ChevronRight className="h-4 w-4" />
                                </Button>
                            </div>
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    )
}
