import { DataTable } from '@/components/data-table'
import { getPreachesForCollection } from '@/lib/services/collections'
import React from 'react'
import { columns } from '../../preaches/columns'

export default async function CollectionPreachesPage({ params }: { params: Promise<{ collectionId: string }> }) {
  const { collectionId } = await params
  const preaches = await getPreachesForCollection(Number(collectionId))

  return (
    <div className="flex flex-col gap-4 p-4">
      <h1 className="text-2xl font-bold">Celebraciones domingo</h1>
      <DataTable columns={columns} data={preaches} />
    </div>
  )
}
