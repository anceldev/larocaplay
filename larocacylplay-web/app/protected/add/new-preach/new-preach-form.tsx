'use client'

import React from 'react'
import { zodResolver } from '@hookform/resolvers/zod'
import { Controller, useForm } from 'react-hook-form'
import { z } from 'zod'
import { Input } from '@/components/ui/input'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Button } from '@/components/ui/button'
import { DateTimePicker } from '@/components/date-time-picker'
import { Preacher } from '@/lib/types'
import { Field, FieldContent, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from 'sonner'
import { error } from 'console'
import { createPreach } from '@/lib/services/preaches'

const formSchema = z.object({
  title: z.string().min(2, { message: "El título debe tener al menos 2 carácteres" }).max(50),
  description: z.string().optional(),
  date: z.date(),
  preacher_id: z.number().min(1, { message: "Debes seleccionar un predicador" }),
  video_url: z.string().min(1, { message: "Debes introducir la url del video" }),
})



export default function NewPreachForm({preachers}:{ preachers: Preacher[] }) {
  
  // Create a date with current date but time set to 11:30:00 AM
  const getDefaultDate = () => {
    const now = new Date()
    const defaultDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 11, 30, 0, 0)
    return defaultDate
  }

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      description: undefined,
      date: getDefaultDate(),
      preacher_id: 0,
      video_url: ""
    }
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      const data = await createPreach({
        title: values.title,
        description: values.description,
        date: values.date,
        preacher_id: values.preacher_id,
        video_url: values.video_url
      })
      if (data == true) {
        toast.success("Predicación añadida")
      }

    } catch {
      toast.error("Error al añadir la predicación")
    }
    console.log(values)
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
                placeholder="Login button not working on mobile"
                autoComplete="off"
              />
              <FieldDescription>
                Título de la predicación
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
                placeholder="Login button not working on mobile"
                autoComplete="off"
              />
              <FieldDescription>
                Breve descripción de la predicación.
              </FieldDescription>
              {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
            </Field>
          )}
        />

        <Controller
          name="date"
          control={form.control}
          render={({ field, fieldState }) => (
            <Field data-invalid={fieldState.invalid}>
              <FieldLabel htmlFor={field.name}>Fecha</FieldLabel>
              <DateTimePicker 
                value={field.value}
                onChange={field.onChange}
              />
              <FieldDescription>
                Fecha de la predicación
              </FieldDescription>
              {fieldState.invalid && <FieldError errors={[fieldState.error]} />}
            </Field>
          )}
        />
        <Controller
          name="preacher_id"
          control={form.control}
          render={({ field, fieldState }) => (
            <Field orientation="responsive" data-invalid={fieldState.invalid}>
              <FieldContent>
                <FieldLabel htmlFor="form-rhf-select-preacher">
                  Predicador
                </FieldLabel>
                <FieldDescription>
                  Selecciona el predicador.
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
                  {preachers.map((preacher: Preacher) => (
                    <SelectItem key={preacher.id} value={String(Number(preacher.id))}>
                      {preacher.preacher_role_id?.name ?? ""} {preacher.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </Field>
          )}
        />

        <FormField
            control={form.control}
            name="video_url"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Video url</FormLabel>
                <FormControl>
                  <Input placeholder="video url" {...field} />
                </FormControl>
                <FormDescription>
                  Url del video de la predicación
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
            />

        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
