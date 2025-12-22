import React from 'react'
import NewPreachForm from './new-preach-form'
import { getPreachers } from '@/lib/services/preacher'

export default async function Page() {
  const preachers = await getPreachers()
  return (
    <NewPreachForm preachers={preachers}/>
  )
}
