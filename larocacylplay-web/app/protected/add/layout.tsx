import { Button } from '@/components/ui/button'
import { ButtonGroup } from '@/components/ui/button-group'
import Link from 'next/link'
import React from 'react'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className='flex flex-col p-8 gap-y-2'>
      <ButtonGroup className='py-5'>
        <Button variant="outline">
          <Link href={"/protected/add/new-preach"}>Nueva predicación</Link>
        </Button>
        <Button variant="outline">
          <Link href={"/protected/add/new-preacher"}>Nuevo predicador</Link>
        </Button>
        <Button variant="outline">
          <Link href={"/protected/add/new-collection"}>Nuevo colección</Link>
        </Button>
      </ButtonGroup>
      <div>
        {children}
      </div>
    </div>
  )
}
