import { redirect } from 'next/navigation'
import { LogoutButton } from '@/components/logout-button'
import { createClient } from '@/lib/supabase/server'
import NewPreachForm from '@/components/forms/new-preach-form'
import { getPreachers } from '@/lib/services/preacher'
import { getEvents } from '@/lib/services/event'
import { getSeries } from '@/lib/services/series'
import NewEventForm from '@/components/forms/new-event-form'
import NewSerieForm from '@/components/forms/new-serie-form'
import { SidebarInset, SidebarProvider } from '@/components/ui/sidebar'
import { AppSidebar } from '@/components/app-sidebar'
import { SiteHeader } from '@/components/site-header'

export default async function ProtectedPage() {
  const supabase = await createClient()
  // const preachers = await getPreachers()
  // const series = await getSeries()
  // const events = await getEvents()

  const { data, error } = await supabase.auth.getClaims()
  if (error || !data?.claims) {
    redirect('/auth/login')
  }

  return (
    <p>ProtectedPage</p>
    // <SidebarProvider>
    //   <AppSidebar variant='inset' />
    //   <SidebarInset>
    //     <SiteHeader />
    //     <div className="flex flex-1 flex-col">
    //     </div>
    //   </SidebarInset>
    // </SidebarProvider>
  )
}
