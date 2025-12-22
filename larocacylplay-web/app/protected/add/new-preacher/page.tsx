import React from 'react'
import NewPreacherForm from './new-preacher-form'
import { getPreachersRoles } from '@/lib/services/preacher'

export default async function Page() {
  const preacherRoles = await getPreachersRoles()
  return (
    <div>
      <NewPreacherForm preacherRoles={preacherRoles} />
    </div>
  )
}
