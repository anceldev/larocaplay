import React from 'react'
import { getPreachCollections } from '@/lib/services/collections'
import { DataTable } from '@/components/data-table'
import { columns } from './columns'

export default async function CollectionsPage() {
  const collections = await getPreachCollections()

  return (
    <div className="flex flex-col p-4 gap-2">
      <h1 className="text-2xl font-bold">Colecciones</h1>
      <DataTable columns={columns} data={collections} />
    </div>
  )
}
