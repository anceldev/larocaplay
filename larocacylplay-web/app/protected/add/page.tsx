import Link from 'next/link'
import React from 'react'

export default function AddPage() {
  return (
    <div className='flex flex-col w-1/2'>
      <Link href={"/protected/add/new-preach"}>Nueva predica</Link>
    </div>
  )
}
