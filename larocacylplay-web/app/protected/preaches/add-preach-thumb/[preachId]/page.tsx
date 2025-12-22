'use client'

import FileUpload from '@/components/file-upload'
import { updatePreachPhoto } from '@/lib/services/preaches'
import React from 'react'
import { toast } from 'sonner'
import { use } from 'react'

export default function Page({ params }: { params: Promise<{ preachId: string }> }) {
  const { preachId } = use(params)

  const handleUploadSuccess = async (filename: string) => {
    try {
      await updatePreachPhoto(Number(preachId), filename)
      toast.success("Portada añadida correctamente")
    } catch (error){
      console.log(error)
      console.log("Error actualizando preach")
      toast.error("Error actualizando preach")
    }
  }

  const handleUploadError = (errors: { name: string, message: string }[]) => {
    console.log('Error en la subida:', errors)
    toast.error("Error en la subida")
  }

  return (
    <div className='flex flex-col p-4 space-y-8'>
      <h1 className='text-2xl font-bold'>Añadir portada de predicación</h1>
      <FileUpload 
        bucketName='app' 
        path={`preaches/`}
        onSuccess={handleUploadSuccess}
        onError={handleUploadError}
      />
    </div>
  )
}
