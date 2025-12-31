// 'use client'
import { getShortCollections } from '@/lib/services/collections'
import { getPreach } from '@/lib/services/preaches'
import React from 'react'
import PreachToCollectionForm from '../preach-to-collection-form'

export default async function Page({ params }: { params: Promise<{ preachId: string }> }) {
  const { preachId } = await params
  const collections = await getShortCollections()
  const preach = await getPreach(Number(preachId))
  return (
    <div className='flex flex-col p-8 space-y-6'>
      <h1 className="flex text-2xl font-bold">Añadir a colección</h1>
      <div className='flex flex-col'>
        <h2 className='text-2xl font-semibold'>{preach.title} - {preach.preacher.preacher_role_id.name} {preach.preacher.name}</h2>
        <h3>{preach.description}</h3>
        <PreachToCollectionForm preach={preach} collections={collections} />
      </div>
    </div>
  )
}
