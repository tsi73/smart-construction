import { ReactNode } from 'react'
import { AnnouncementBanner } from '@/components/announcement-banner'

export default function AdminLayout({ children }: { children: ReactNode }) {
    return (
        <div className="min-h-screen flex flex-col bg-background">
            <AnnouncementBanner />
            <div className="flex-1 min-h-0">{children}</div>
        </div>
    )
}
