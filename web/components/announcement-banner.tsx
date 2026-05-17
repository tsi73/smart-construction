'use client'

import { useEffect, useState } from 'react'
import { AlertTriangle, Info, Megaphone, X } from 'lucide-react'
import { listAnnouncements } from '@/lib/api'
import type { AnnouncementItem } from '@/lib/api-types'

const PRIORITY_LABELS: Record<string, string> = {
    urgent: 'Urgent',
    high: 'Important',
    normal: 'Announcement',
    low: 'Notice',
}

function priorityStyles(priority: string) {
    switch (priority) {
        case 'urgent':
            return 'bg-red-600 text-white'
        case 'high':
            return 'bg-orange-500 text-white'
        case 'low':
            return 'bg-slate-700 text-slate-50'
        default:
            return 'bg-blue-600 text-white'
    }
}

function PriorityIcon({ priority }: { priority: string }) {
    if (priority === 'urgent' || priority === 'high') {
        return <AlertTriangle className="h-5 w-5 shrink-0" aria-hidden />
    }
    if (priority === 'low') {
        return <Info className="h-5 w-5 shrink-0" aria-hidden />
    }
    return <Megaphone className="h-5 w-5 shrink-0" aria-hidden />
}

export function AnnouncementBanner() {
    const [announcements, setAnnouncements] = useState<AnnouncementItem[]>([])
    const [dismissedIds, setDismissedIds] = useState<Set<string>>(new Set())
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        let cancelled = false
            ; (async () => {
                try {
                    const data = await listAnnouncements()
                    if (!cancelled) setAnnouncements(data)
                } catch {
                    // silent
                } finally {
                    if (!cancelled) setLoading(false)
                }
            })()
        return () => { cancelled = true }
    }, [])

    const visible = announcements.filter((a) => !dismissedIds.has(a.id))

    if (loading || visible.length === 0) return null

    return (
        <div className="w-full">
            {visible.map((a) => (
                <div
                    key={a.id}
                    role="alert"
                    className={`flex items-center gap-3 px-4 py-3 sm:px-6 ${priorityStyles(a.priority)}`}
                >
                    <PriorityIcon priority={a.priority} />
                    <span className="hidden sm:inline-flex items-center rounded-sm bg-black/20 px-2 py-0.5 text-[11px] font-extrabold uppercase tracking-widest">
                        {PRIORITY_LABELS[a.priority] || 'Announcement'}
                    </span>
                    <div className="flex-1 text-center text-sm font-extrabold uppercase tracking-wide leading-snug sm:text-base">
                        {a.content}
                    </div>
                    <button
                        type="button"
                        aria-label="Dismiss announcement"
                        className="shrink-0 rounded-sm p-1 opacity-80 hover:bg-black/20 hover:opacity-100 transition"
                        onClick={() => setDismissedIds((prev) => new Set([...prev, a.id]))}
                    >
                        <X className="h-4 w-4" />
                    </button>
                </div>
            ))}
        </div>
    )
}
