'use client'

import React from 'react'
import { zodResolver } from '@hookform/resolvers/zod'
import { Controller, useForm } from 'react-hook-form'
import { z } from 'zod'
import { Input } from '@/components/ui/input'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Button } from '@/components/ui/button'
import { DateTimePicker } from '@/components/date-time-picker'
import { Preacher, PreacherRole } from '@/lib/types'
import { Field, FieldContent, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from 'sonner'
import { error } from 'console'
import { createPreach } from '@/lib/services/preaches'
import { createNewPreacher } from '@/lib/services/preacher'

const formSchema = z.object({
  name: z.string().min(2, { message: "El título debe tener al menos 2 carácteres" }).max(50),
  preacher_role_id: z.number().min(1, { message: "Debes seleccionar un predicador" }),
})



export default function NewPreacherForm({preacherRoles}:{ preacherRoles: PreacherRole[] }) {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: "",
      preacher_role_id: 0,
    }
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      const data = await createNewPreacher({
        name: values.name
      })

      if (data == true) {
        toast.success("Predicador añadido")
      }

    } catch {
      toast.error("Error al añadir nuevo predicador")
    }
    console.log(values)
  }
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <Controller
          name="name"
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
          name="preacher_role_id"
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
                  {preacherRoles.map((role: PreacherRole) => (
                    <SelectItem key={role.id} value={String(Number(role.id))}>
                      {role.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </Field>
          )}
        />

        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}

