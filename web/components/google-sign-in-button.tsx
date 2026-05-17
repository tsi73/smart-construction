'use client'

import { useEffect, useRef, useState } from 'react'
import { Loader2 } from 'lucide-react'
import { useAuth } from '@/lib/auth-context'
import { useRouter } from 'next/navigation'

const GSI_SRC = 'https://accounts.google.com/gsi/client'

type GoogleCredentialResponse = { credential?: string }

declare global {
  interface Window {
    google?: {
      accounts: {
        id: {
          initialize: (config: {
            client_id: string
            callback: (resp: GoogleCredentialResponse) => void
            auto_select?: boolean
            ux_mode?: 'popup' | 'redirect'
          }) => void
          renderButton: (
            parent: HTMLElement,
            opts: Record<string, unknown>,
          ) => void
        }
      }
    }
  }
}

function loadGsiScript(): Promise<void> {
  if (typeof window === 'undefined') return Promise.resolve()
  if (window.google?.accounts?.id) return Promise.resolve()

  return new Promise((resolve, reject) => {
    const existing = document.querySelector<HTMLScriptElement>(
      `script[src="${GSI_SRC}"]`,
    )
    if (existing) {
      existing.addEventListener('load', () => resolve())
      existing.addEventListener('error', () => reject(new Error('Failed to load Google script')))
      return
    }
    const script = document.createElement('script')
    script.src = GSI_SRC
    script.async = true
    script.defer = true
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('Failed to load Google script'))
    document.head.appendChild(script)
  })
}

// GSI is a global singleton on window.google. Initialize once per client_id —
// otherwise StrictMode double-effects and route changes log
// "google.accounts.id.initialize() is called multiple times". The callback
// dispatches via a ref so each mounted component can swap in its own handler.
let gsiInitializedClientId: string | null = null
let gsiCurrentHandler: ((credential: string) => void) | null = null

async function ensureGsiInitialized(clientId: string): Promise<void> {
  await loadGsiScript()
  if (!window.google?.accounts?.id) {
    throw new Error('Google Identity Services unavailable')
  }
  if (gsiInitializedClientId === clientId) return
  window.google.accounts.id.initialize({
    client_id: clientId,
    ux_mode: 'popup',
    callback: (resp) => {
      if (resp.credential && gsiCurrentHandler) gsiCurrentHandler(resp.credential)
    },
  })
  gsiInitializedClientId = clientId
}

export function GoogleSignInButton({ onError }: { onError?: (msg: string) => void }) {
  const router = useRouter()
  const { loginWithGoogle } = useAuth()
  const containerRef = useRef<HTMLDivElement | null>(null)
  const [signingIn, setSigningIn] = useState(false)
  const [scriptError, setScriptError] = useState<string | null>(null)

  const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID

  useEffect(() => {
    if (!clientId) {
      setScriptError('Google Sign-In is not configured.')
      return
    }
    let cancelled = false

    const handler = async (credential: string) => {
      setSigningIn(true)
      const result = await loginWithGoogle(credential)
      setSigningIn(false)
      if (result.success) {
        router.push('/dashboard')
      } else {
        onError?.(result.error || 'Google sign-in failed')
      }
    }

    ensureGsiInitialized(clientId)
      .then(() => {
        if (cancelled || !window.google?.accounts?.id || !containerRef.current) return
        gsiCurrentHandler = handler
        // Clear container in case of remount — renderButton appends, doesn't replace.
        containerRef.current.innerHTML = ''
        window.google.accounts.id.renderButton(containerRef.current, {
          type: 'standard',
          theme: 'outline',
          size: 'large',
          text: 'continue_with',
          shape: 'rectangular',
          logo_alignment: 'left',
          width: containerRef.current.clientWidth || 320,
        })
      })
      .catch((err: Error) => {
        if (!cancelled) setScriptError(err.message)
      })

    return () => {
      cancelled = true
      if (gsiCurrentHandler === handler) gsiCurrentHandler = null
    }
  }, [clientId, loginWithGoogle, router, onError])

  if (!clientId) {
    return (
      <p className="text-xs text-muted-foreground text-center">
        Google Sign-In not configured. Set <code>NEXT_PUBLIC_GOOGLE_CLIENT_ID</code>.
      </p>
    )
  }

  if (scriptError) {
    return <p className="text-xs text-destructive text-center">{scriptError}</p>
  }

  return (
    <div className="w-full flex justify-center min-h-[40px]">
      {signingIn ? (
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Loader2 className="h-4 w-4 animate-spin" />
          Signing in with Google…
        </div>
      ) : (
        <div ref={containerRef} className="w-full flex justify-center" />
      )}
    </div>
  )
}
