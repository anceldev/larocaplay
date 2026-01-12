'use client'

import React from 'react'
import { zodResolver } from '@hookform/resolvers/zod'
import { Controller, useForm } from 'react-hook-form'
import { z } from 'zod'
import { Input } from '@/components/ui/input'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Button } from '@/components/ui/button'
import { DateTimePicker } from '@/components/date-time-picker'
import { Collection, CollectionType, Preacher } from '@/lib/types'
import { Field, FieldContent, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from 'sonner'
import { collectionTypes } from '@/lib/constants'
import { Switch } from '@/components/ui/switch'
import { createCollection } from '@/lib/services/collections'

const formSchema = z.object({
  title: z.string().min(2, { message: "El título debe tener al menos 2 carácteres" }).max(50),
  description: z.string().optional(),
  collection_type_id: z.number().min(1, { message: "Debes seleccionar un tipo de colección" }),
  is_public: z.boolean(),
  is_home_screen: z.boolean(),
  created_at: z.date(),
})

export default function NewCollectionForm() {

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      description: undefined,
      collection_type_id: 5,
      is_public: true,
      is_home_screen: false,
      created_at: new Date(),
    }
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      console.log("Insertando colección")
      console.log(values)
      const newCollection = await createCollection({
        title: values.title,
        description: values.description,
        image_id: undefined,
        is_public: values.is_public,
        is_home_screen: values.is_home_screen,
        collection_type_id: values.collection_type_id,
        created_at: values.created_at,
      })
      if (newCollection === true) {
        toast.success("Colección añadida")
      }
    } catch (error) {
      console.log("Error al añadir la colección", error)
      toast.error("Error al añadir la colección")
    }
  }
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <Controller
          name="title"
          control={form.control}
          render={({ field, fieldState }) => (
            <Field data-invalid={fieldState.invalid}>
              <FieldLabel htmlFor={field.name}>Título</FieldLabel>
              <Input
                {...field}
                id={field.name}
                aria-invalid={fieldState.invalid}
                placeholder="Nombre de la colección"
                autoComplete="off"
              />
              <FieldDescription>
                Nombre de la colección
              </FieldDescription>
              {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
            </Field>
          )}
        />

        <Controller
          name="description"
          control={form.control}
          render={({ field, fieldState }) => (
            <Field data-invalid={fieldState.invalid}>
              <FieldLabel htmlFor={field.name}>Descripción</FieldLabel>
              <Input
                {...field}
                id={field.name}
                aria-invalid={fieldState.invalid}
                placeholder="Breve descripción de la colección"
                autoComplete="off"
              />
              <FieldDescription>
                Breve descripción de la colección.
              </FieldDescription>
              {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
            </Field>
          )}
        />
        <div className='flex gap-x-4 items-start'>
          <Controller
            name="created_at"
            control={form.control}
            render={({ field, fieldState }) => (
              <Field data-invalid={fieldState.invalid}>
                <FieldLabel htmlFor={field.name}>Fecha de creación</FieldLabel>
                <FieldDescription>Selecciona la fecha de creación de la colección.</FieldDescription>
                <DateTimePicker
                  value={field.value}
                  onChange={field.onChange}
                />
                {/* <FieldDescription>
                Fecha de la predicación
              </FieldDescription> */}
                {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
              </Field>
            )}
          />
          <Controller
            name="collection_type_id"
            control={form.control}
            render={({ field, fieldState }) => (
              <Field orientation="responsive" data-invalid={fieldState.invalid}>
                <FieldContent>
                  <FieldLabel htmlFor="form-rhf-select-preacher">Tipo de colección</FieldLabel>
                  <FieldDescription>
                    Selecciona el tipo de colección.
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
                    {collectionTypes.map((collection: CollectionType) => (
                      <SelectItem key={collection.id} value={String(Number(collection.id))}>
                        {collection.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
            )}
          />
          <FormField
          control={form.control}
          name="is_public"
          render={({ field }) => (
            <FormItem className="rounded-lg border p-4 text-center flex flex-col items-center justify-center">
              <FormLabel>¿Colleción pública?</FormLabel>
              <FormDescription>
                Hacer que esta colección sea visible para todos los miembros.
              </FormDescription>
              <span className={`font-bold ${field.value ? "text-green-800" : "text-red-500"}`}>{field.value ? "Si" : "No"}</span>
              <FormControl>
                {/* Conexión manual de las propiedades del Switch */}
                <Switch
                  checked={field.value}
                  onCheckedChange={field.onChange}
                />
              </FormControl>
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="is_home_screen"
          render={({ field }) => (
            <FormItem className="rounded-lg border p-4">
              <FormLabel>Mostrar en la pantalla principal</FormLabel>
              <FormDescription>
                Hacer que esta colección sea visible en la pantalla principal.
              </FormDescription>
              <span className={`font-bold ${field.value ? "text-green-800" : "text-red-500"}`}>{field.value ? "Si" : "No"}</span>
            <FormControl>
              {/* Conexión manual de las propiedades del Switch */}
              <Switch
                checked={field.value}
                onCheckedChange={field.onChange}
              />
            </FormControl>
          </FormItem>
          )}
        />
        </div>
        <Button type="submit">Añadir colección</Button>
      </form>
    </Form>
  )
}
