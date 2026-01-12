'use client'
import FileUpload from '@/components/file-upload'
import React from 'react'
import { toast } from 'sonner'

export default function AddCollectionImagePage({ params }: { params: Promise<{ collectionId: string }> }) {
  const { collectionId } = React.use(params)

  const metadata = React.useMemo(() => ({
    target_id: Number(collectionId), // Forzamos a que sea un número real
    table_target: 'collection',
  }), [collectionId]);
  
  const handleUploadError = (errors: { name: string; message: string }[]) => {
    console.error('Error en la subida:', errors)
    toast.error("Error en la subida")
  }
  return (
    <div className='p-4 space-y-6'>
      <h1 className='text-2xl font-bold'>Añadir imagen de colección</h1>
      <FileUpload
        bucketName='app'
        path={`collection/`}
        metadata={metadata}
        onError={handleUploadError}
      />
    </div>
  )
}
