'use client'
import FileUpload from '@/components/file-upload'
import React from 'react'
import { toast } from 'sonner'

export default function AddPreacherPhotoPage({ params }: { params: Promise<{ preacherId: string }> }) {
  const { preacherId } = React.use(params)

  const metadata = React.useMemo(() => ({
    target_id: Number(preacherId), // Forzamos a que sea un número real
    table_target: 'preacher',
  }), [preacherId]);
  
  const handleUploadError = (errors: { name: string; message: string }[]) => {
    console.error('Error en la subida:', errors)
    toast.error("Error en la subida")
  }

  return (
    <div className='p-4 space-y-6'>
      <h1 className='text-2xl font-bold'>Añadir foto al predicador</h1>
      <FileUpload 
      bucketName='app' 
      path={`preacher/`}
      onError={handleUploadError}
      metadata={metadata}
      />
    </div>
  )
}
