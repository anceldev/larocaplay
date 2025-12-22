'use client'

import FileUpload from '@/components/file-upload'
import { updateCollectionPhoto } from '@/lib/services/collections'
import React from 'react'
import { toast } from 'sonner'
import { use } from 'react'
// import { useRouter } from 'next/navigation'

export default function AddCollectionPhotoPage({ params }: { params: Promise<{ collectionId: string }> }) {
  const { collectionId } = use(params)
  // const router = useRouter()

  const handleUploadSuccess = async (fileName: string) => {
    try {
      const updated = await updateCollectionPhoto(Number(collectionId), fileName)
      console.log(updated)
      toast.success("Portada añadida correctamente")
    } catch (error) {
      console.log("error actualizando campo en tabla")
      console.log(error)
    }
  }

  const handleUploadError = (errors: { name: string; message: string }[]) => {
    console.error('Error en la subida:', errors)
    
  }

  return (
    <div className='flex flex-col p-4 space-y-8'>
      <h1 className='text-2xl font-bold'>Añadir portada de colección</h1>
      <FileUpload 
        bucketName='app' 
        path={`collections/`}
        onSuccess={handleUploadSuccess}
        onError={handleUploadError}
      />
    </div>
  )
}
