import { DataTable } from '@/components/data-table'
import { getPreachers } from '@/lib/services/preacher'
import React from 'react'
import { columns } from './columns'


export default async function PreachersPage() {
  const preachers = await getPreachers()
  return (
    <div className="p-4 space-y-6">
      <h1 className="text-2xl font-bold">Predicadores</h1>
      <DataTable columns={columns} data={preachers} />
    </div>
  )
}
