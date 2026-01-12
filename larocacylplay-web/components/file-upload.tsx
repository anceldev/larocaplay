'use client'

import { useSupabaseUpload } from '@/hooks/use-supabase-upload'
import React, { useEffect, useRef } from 'react'
import { Dropzone, DropzoneContent, DropzoneEmptyState } from './dropzone'

interface FileUploadProps {
  bucketName: string
  path: string,
  metadata?: Record<string, string | number> | ((file: File) => Record<string, string | number>), //
  onError?: (errors: { name: string; message: string }[]) => void
}

export default function FileUpload({
  bucketName,
  path,
  metadata,
  onError
}: FileUploadProps) {
  const props = useSupabaseUpload({
    bucketName: bucketName,
    path: path,
    allowedMimeTypes: ['image/*'],
    maxFiles: 1,
    maxFileSize: 1000 * 1000 * 5, // 5MB,
    upsert: true,
    metadata: metadata
  })

  const { isSuccess, successes, errors, loading } = props
  const prevLoadingRef = useRef(loading)
  const prevSuccessesRef = useRef<string[]>([])
  const prevErrorsRef = useRef<{ name: string; message: string }[]>([])

  // Detectar cuando la subida termina (loading pasa de true a false)
  useEffect(() => {
    // Si estaba cargando y ahora no está cargando, la subida terminó
    if (prevLoadingRef.current && !loading) {
      if (errors.length > 0) {
        // Hay errores
        onError?.(errors)
      }
    }
    
    prevLoadingRef.current = loading
    prevSuccessesRef.current = successes
    prevErrorsRef.current = errors
  }, [loading, isSuccess, successes, errors, path, onError])

  return (
    <div className='flex flex-col gap-2 w-1/2'>
      <Dropzone {...props}>
        <DropzoneEmptyState />
        <DropzoneContent />
      </Dropzone>
    </div>
  )
}
