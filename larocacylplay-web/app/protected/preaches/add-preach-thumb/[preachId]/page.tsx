'use client'

import FileUpload from '@/components/file-upload'
import React from 'react'
import { toast } from 'sonner'
import { use } from 'react'

export default function Page({ params }: { params: Promise<{ preachId: string }> }) {
  const { preachId } = use(params)
  
  const metadata = React.useMemo(() => ({
    target_id: Number(preachId  ), // Forzamos a que sea un número real
    table_target: 'preach',
  }), [preachId]);

  const handleUploadError = (errors: { name: string, message: string }[]) => {
    console.error('Error en la subida:', errors)
    toast.error("Error en la subida")
  }

  return (
    <div className='flex flex-col p-4 space-y-8'>
      <h1 className='text-2xl font-bold'>Añadir portada de predicación</h1>
      <FileUpload 
        bucketName='app' 
        path={`preach/`}
        onError={handleUploadError}
        metadata={metadata}
      />
    </div>
  )
}
