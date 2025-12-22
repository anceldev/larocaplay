'use client'

import React from 'react'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'

import { Button } from '@/components/ui/button'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { useForm } from 'react-hook-form'
// import { createSeries } from '@/lib/services/series-client'
import { createSeries } from '@/lib/services/series'
import { useState } from 'react'
import { toast } from 'sonner'

const formSchema = z.object({
  name: z.string().min(1, 
    { message: 'El nombre es requerido' }
  ),
  description: z.string().optional(),
})

export default function NewSerieForm() {
  const [isLoading, setIsLoading] = useState(false)

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: '',
      description: '',
    },
  })

  const onSubmit = async (data: z.infer<typeof formSchema>) => {
    try {
      setIsLoading(true)
      const series = await createSeries({
        name: data.name,
        description: data.description || undefined,
      })
      console.log('Serie creada:', series)
      toast.success('Serie creada correctamente')
      setIsLoading(false)
      form.reset()
    } catch (error) {
      console.error('Error al crear serie:', error)
      toast.error('Error al crear la serie. Inténtalo de nuevo.')
      setIsLoading(false)
    }
    // setIsLoading(true)
    
    // try {
    //   const series = await createSeries({
    //     name: data.name,
    //     description: data.description || undefined,
    //   })
    //   console.log('Serie creada:', series)
    //   toast.success('Serie creada correctamente')
    //   form.reset()
    // } catch (error) {
    //   console.error('Error al crear serie:', error)
    //   toast.error('Error al crear la serie. Inténtalo de nuevo.')
    // } finally {
    //   setIsLoading(false)
    // }
  }
  
  return (
    <div className="flex flex-col gap-4">
      <h1 className="text-2xl font-bold">Nueva serie</h1>      
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Nombre</FormLabel>
                <FormControl>
                  <Input placeholder="Título de la serie" {...field} />
                </FormControl>
                <FormDescription>
                  Nombre de la serie.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Descripción</FormLabel>
                <FormControl>
                  <Input placeholder="Descripción de la serie" {...field} />
                </FormControl>
                <FormDescription>
                  Descripción de la serie.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
          <Button type="submit" disabled={isLoading}>
            {isLoading ? 'Creando...' : 'Crear Serie'}
          </Button>
        </form>
      </Form>
    </div>
  )
}
