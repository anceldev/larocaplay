'use client'

import { ShortCollection, ShortPreach } from '@/lib/types'
import React from 'react'
import z from 'zod'
import { Controller, useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Field, FieldContent, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { toast } from 'sonner'
import { addPreachToCollection } from '@/lib/services/preaches'

const formSchema = z.object({
  position: z.number().optional(),
  collection_id: z.number().min(1, { message: "Debes seleccionar una colección" })
})

export default function PreachToCollectionForm({ preach, collections }: { preach: ShortPreach, collections: ShortCollection[] }) {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      position: undefined,
      collection_id: 1,
    }
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      console.log("Añadiendo a colección")
      const data = await addPreachToCollection({
        preachId: preach.id,
        collectionId: values.collection_id,
        position: values.position
      })
      console.log("Añadido a colección")
      if(data == true) {
        toast.success("Predica añadida a colección")
      }

    } catch (error) {
      console.log(error)
      toast.error("Error añadiendo a colección")
    }
  }
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <div className='flex gap-x-4'>
          <Controller
            name="collection_id"
            control={form.control}
            render={({ field, fieldState }) => (
              <Field orientation="responsive" data-invalid={fieldState.invalid} className='flex w-1/2'>
                <FieldContent>
                  <FieldLabel htmlFor="form-rhf-select-preacher">Serie</FieldLabel>
                  <FieldDescription>
                    Selecciona la serie.
                  </FieldDescription>
                  {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
                </FieldContent>
                <Select
                  name={field.name}
                  value={field.value ? String(field.value) : undefined}
                  onValueChange={(value) => field.onChange(Number(value))}
                >
                  <SelectTrigger
                    id="form-rhf-select-preacher"
                    aria-invalid={fieldState.invalid}
                    className="min-w-[120px]"
                  >
                    <SelectValue placeholder="Seleccionar predicador..." />
                  </SelectTrigger>
                  <SelectContent position="item-aligned">
                    {collections.map((collection: ShortCollection) => (
                      <SelectItem key={collection.id} value={String(Number(collection.id))}>
                        {collection.title}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
            )}
          />
          <FormField
            control={form.control}
            name="position"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Posición en la colección</FormLabel>
                <FieldDescription>Posición en la serie</FieldDescription>
                <FormControl>
                  <Input
                    type="number"
                    placeholder="Posición (opcional)"
                    value={field.value ?? ''}
                    onChange={(e) => {
                      const value = e.target.value
                      field.onChange(value === '' ? undefined : Number(value))
                    }}
                  />
                </FormControl>
                {/* <FormDescription>
                  Posición del video en la colección (opcional)
                </FormDescription> */}
                <FormMessage />
              </FormItem>
            )}
          />
        </div>


        <Button type="submit">Añadir</Button>
      </form>
    </Form>
  )
}
