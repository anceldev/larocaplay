import { getPreachesForCollection } from '@/lib/services/collections';
import React from 'react'
import { DataTable } from '@/components/data-table';
import { columns } from './columns';

export default async function PreachesPage() {
  const preaches = await getPreachesForCollection(1);
  return (
    <div className="flex flex-col gap-4 p-4">
      <h1 className="text-2xl font-bold">Celebraciones domingo</h1>
      <DataTable columns={columns} data={preaches} />
    </div>
  )
}
