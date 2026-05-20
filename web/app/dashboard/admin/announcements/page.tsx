'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useAuth } from '@/lib/auth-context'
import {
    listAllAnnouncements,
    createAnnouncement,
    updateAnnouncement,
    deleteAnnouncement,
} from '@/lib/api'
import type { AnnouncementItem } from '@/lib/api-types'
import { Loader2, Plus, Edit, Trash2, ArrowLeft } from 'lucide-react'
import { useToast } from '@/hooks/use-toast'
import { useLanguage } from '@/lib/language-context'

export default function AdminAnnouncementsPage() {
    const router = useRouter()
    const { user, isAuthenticated, isLoading: authLoading } = useAuth()
    const { toast } = useToast()
    const { t } = useLanguage()
    const [announcements, setAnnouncements] = useState<AnnouncementItem[]>([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)
    const [dialogOpen, setDialogOpen] = useState(false)
    const [editingAnnouncement, setEditingAnnouncement] = useState<AnnouncementItem | null>(null)
    const [formData, setFormData] = useState({
        content: '',
        priority: 'normal',
        target_audience: 'all' as 'all' | 'admins' | 'project_managers',
        expires_at: '',
    })
    const [saving, setSaving] = useState(false)

    useEffect(() => {
        if (!authLoading && !isAuthenticated) {
            router.push('/login')
        }
        if (!authLoading && isAuthenticated && !user?.is_admin) {
            router.push('/dashboard')
        }
    }, [authLoading, isAuthenticated, user, router])

    const loadAnnouncements = async () => {
        setLoading(true)
        setError(null)
        try {
            const data = await listAllAnnouncements()
            setAnnouncements(data)
        } catch (err) {
            setError(err instanceof Error ? err.message : t('announcementsPage.failedToLoad'))
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        if (!isAuthenticated || !user?.is_admin) return
        loadAnnouncements()
    }, [isAuthenticated, user])

    const handleOpenDialog = (announcement?: AnnouncementItem) => {
        if (announcement) {
            setEditingAnnouncement(announcement)
            setFormData({
                content: announcement.content,
                priority: announcement.priority,
                target_audience: (announcement.target_audience as 'all' | 'admins' | 'project_managers') || 'all',
                expires_at: announcement.expires_at
                    ? new Date(announcement.expires_at).toISOString().slice(0, 16)
                    : '',
            })
        } else {
            setEditingAnnouncement(null)
            setFormData({
                content: '',
                priority: 'normal',
                target_audience: 'all',
                expires_at: '',
            })
        }
        setDialogOpen(true)
    }

    const handleSave = async () => {
        if (!formData.content) {
            toast({
                title: t('announcementsPage.error'),
                description: t('announcementsPage.contentRequired'),
                variant: 'destructive',
            })
            return
        }

        const derivedTitle = formData.content.trim().split(/\s+/).slice(0, 6).join(' ') || 'Announcement'

        setSaving(true)
        try {
            const payload = {
                title: derivedTitle,
                content: formData.content,
                priority: formData.priority,
                target_audience: formData.target_audience,
                expires_at: formData.expires_at || undefined,
            }

            if (editingAnnouncement) {
                await updateAnnouncement(editingAnnouncement.id, payload)
                toast({
                    title: t('announcementsPage.success'),
                    description: t('announcementsPage.updatedSuccess'),
                })
            } else {
                await createAnnouncement(payload)
                toast({
                    title: t('announcementsPage.success'),
                    description: t('announcementsPage.createdSuccess'),
                })
            }

            setDialogOpen(false)
            loadAnnouncements()
        } catch (err) {
            toast({
                title: t('announcementsPage.error'),
                description: err instanceof Error ? err.message : t('announcementsPage.failedToSave'),
                variant: 'destructive',
            })
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async (id: string) => {
        if (!confirm(t('announcementsPage.confirmDelete'))) return

        try {
            await deleteAnnouncement(id)
            toast({
                title: t('announcementsPage.success'),
                description: t('announcementsPage.deletedSuccess'),
            })
            loadAnnouncements()
        } catch (err) {
            toast({
                title: t('announcementsPage.error'),
                description: err instanceof Error ? err.message : t('announcementsPage.failedToDelete'),
                variant: 'destructive',
            })
        }
    }

    const handleToggleActive = async (announcement: AnnouncementItem) => {
        try {
            await updateAnnouncement(announcement.id, {
                is_active: !announcement.is_active,
            })
            toast({
                title: t('announcementsPage.success'),
                description: announcement.is_active ? t('announcementsPage.deactivatedSuccess') : t('announcementsPage.activatedSuccess'),
            })
            loadAnnouncements()
        } catch (err) {
            toast({
                title: t('announcementsPage.error'),
                description: err instanceof Error ? err.message : t('announcementsPage.failedToUpdate'),
                variant: 'destructive',
            })
        }
    }

    if (authLoading || (loading && announcements.length === 0)) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        )
    }

    if (!isAuthenticated || !user?.is_admin) return null

    const getPriorityBadge = (priority: string) => {
        switch (priority) {
            case 'urgent':
                return <Badge variant="destructive">{t('announcementsPage.priorityUrgent')}</Badge>
            case 'high':
                return <Badge className="bg-orange-500">{t('announcementsPage.priorityHigh')}</Badge>
            case 'normal':
                return <Badge variant="secondary">{t('announcementsPage.priorityNormal')}</Badge>
            case 'low':
                return <Badge variant="outline">{t('announcementsPage.priorityLow')}</Badge>
            default:
                return <Badge variant="secondary">{priority}</Badge>
        }
    }

    return (
        <div className="p-8 space-y-8">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('announcementsPage.title')}</h1>
                    <p className="text-muted-foreground mt-2">{t('announcementsPage.subtitle')}</p>
                </div>
                <Button onClick={() => handleOpenDialog()} className="gap-2">
                    <Plus className="h-4 w-4" />
                    {t('announcementsPage.newAnnouncement')}
                </Button>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>{t('announcementsPage.allAnnouncements')}</CardTitle>
                    <CardDescription>{t('announcementsPage.allAnnouncementsDesc')}</CardDescription>
                </CardHeader>
                <CardContent>
                    {error ? (
                        <div className="rounded-lg border border-destructive/20 bg-destructive/5 p-4 text-sm text-destructive">
                            {error}
                        </div>
                    ) : loading ? (
                        <div className="flex items-center justify-center py-8">
                            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                        </div>
                    ) : announcements.length === 0 ? (
                        <div className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
                            {t('announcementsPage.noAnnouncements')}
                        </div>
                    ) : (
                        <div className="space-y-2">
                            {announcements.map((announcement) => (
                                <div key={announcement.id} className="flex items-center justify-between gap-3 rounded-lg border px-3 py-2 text-sm">
                                    <div className="min-w-0 flex-1">
                                        <p className="truncate font-bold text-foreground">{announcement.content}</p>
                                    </div>
                                    <div className="flex items-center gap-2 shrink-0">
                                        {getPriorityBadge(announcement.priority)}
                                        {announcement.is_active ? (
                                            <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">{t('announcementsPage.active')}</Badge>
                                        ) : (
                                            <Badge variant="outline" className="bg-gray-50 text-gray-700 border-gray-200">{t('announcementsPage.inactive')}</Badge>
                                        )}
                                        <Badge variant="outline" className="text-[10px]">
                                            {announcement.expires_at
                                                ? new Date(announcement.expires_at).toLocaleDateString('en-US', {
                                                    month: 'short',
                                                    day: 'numeric',
                                                    year: 'numeric',
                                                })
                                                : t('announcementsPage.noExpiry')}
                                        </Badge>
                                        <Button variant="ghost" size="icon" onClick={() => handleToggleActive(announcement)}>
                                            {announcement.is_active ? '—' : '+'}
                                        </Button>
                                        <Button variant="ghost" size="icon" onClick={() => handleOpenDialog(announcement)}>
                                            <Edit className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            variant="ghost"
                                            size="icon"
                                            onClick={() => handleDelete(announcement.id)}
                                            className="text-destructive hover:text-destructive"
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>

            <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
                <DialogContent className="max-w-xl">
                    <DialogHeader>
                        <DialogTitle>{editingAnnouncement ? t('announcementsPage.editAnnouncement') : t('announcementsPage.createAnnouncement')}</DialogTitle>
                        <DialogDescription>
                            {editingAnnouncement
                                ? t('announcementsPage.editAnnouncementDesc')
                                : t('announcementsPage.createAnnouncementDesc')}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-4">
                        <div className="space-y-2">
                            <Label htmlFor="content">{t('announcementsPage.content')}</Label>
                            <Textarea
                                id="content"
                                value={formData.content}
                                onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                                placeholder={t('announcementsPage.contentPlaceholder')}
                                rows={4}
                            />
                        </div>

                        <div className="grid gap-4 sm:grid-cols-3">
                            <div className="space-y-2">
                                <Label htmlFor="priority">{t('announcementsPage.priority')}</Label>
                                <Select
                                    value={formData.priority}
                                    onValueChange={(value) => setFormData({ ...formData, priority: value })}
                                >
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="low">{t('announcementsPage.priorityLow')}</SelectItem>
                                        <SelectItem value="normal">{t('announcementsPage.priorityNormal')}</SelectItem>
                                        <SelectItem value="high">{t('announcementsPage.priorityHigh')}</SelectItem>
                                        <SelectItem value="urgent">{t('announcementsPage.priorityUrgent')}</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>

                            <div className="space-y-2">
                                <Label htmlFor="target_audience">{t('announcementsPage.audience')}</Label>
                                <Select
                                    value={formData.target_audience}
                                    onValueChange={(value) => setFormData({ ...formData, target_audience: value as 'all' | 'admins' | 'project_managers' })}
                                >
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="all">{t('announcementsPage.audienceAll')}</SelectItem>
                                        <SelectItem value="admins">{t('announcementsPage.audienceAdmins')}</SelectItem>
                                        <SelectItem value="project_managers">{t('announcementsPage.audiencePMs')}</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>

                            <div className="space-y-2">
                                <Label htmlFor="expires_at">{t('announcementsPage.expiresAt')}</Label>
                                <Input
                                    id="expires_at"
                                    type="datetime-local"
                                    value={formData.expires_at}
                                    onChange={(e) => setFormData({ ...formData, expires_at: e.target.value })}
                                />
                            </div>
                        </div>
                    </div>

                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDialogOpen(false)} disabled={saving}>
                            {t('announcementsPage.cancel')}
                        </Button>
                        <Button onClick={handleSave} disabled={saving}>
                            {saving ? (
                                <>
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                    {t('announcementsPage.saving')}
                                </>
                            ) : editingAnnouncement ? (
                                t('announcementsPage.update')
                            ) : (
                                t('announcementsPage.create')
                            )}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    )
}
