import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

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
