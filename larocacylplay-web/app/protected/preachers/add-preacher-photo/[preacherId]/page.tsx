'use client'
import FileUpload from '@/components/file-upload'
import { updatePreacherPhoto } from '@/lib/services/preacher'
import React from 'react'

export default function AddPreacherPhotoPage({ params }: { params: { preacherId: string } }) {
  const { preacherId } = params

  const handleUploadSuccess = async (fileName: string) => {
    try {
      await updatePreacherPhoto(Number(preacherId), fileName)
    } catch (error) {
      console.log("error actualizando campo en tabla")
      console.log(error)
    }
  }

  const handleUploadError = (errors: { name: string; message: string }[]) => {
    console.error('Error en la subida:', errors)
    
  }

  return (
    <div className='p-4 space-y-6'>
      <h1 className='text-2xl font-bold'>Añadir foto al predicador</h1>
      <FileUpload 
      bucketName='app' 
      path={`preachers/`}
      onSuccess={handleUploadSuccess}
      onError={handleUploadError}
      />
    </div>
  )
}
