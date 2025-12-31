import React from 'react'
import NewPreachForm from './new-preach-form'
import { getPreachers } from '@/lib/services/preacher'
import { getPreachCollections } from '@/lib/services/collections'

export default async function Page() {
  const preachers = await getPreachers()
  const collections = await getPreachCollections()
  return (
    <NewPreachForm preachers={preachers} collections={collections}/>
  )
}
