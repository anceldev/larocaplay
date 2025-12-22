'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import React, { useState } from 'react'
import { z } from 'zod'
import { Input } from '../ui/input'
import { FormControl, FormLabel, FormItem, FormField, Form, FormDescription, FormMessage } from '../ui/form'
import { useForm } from 'react-hook-form'
import { Popover, PopoverContent, PopoverTrigger } from '../ui/popover'
import { Button } from '../ui/button'
import { cn } from '@/lib/utils'
import { CalendarIcon } from 'lucide-react'
import { format } from 'date-fns'
import { Calendar } from '../ui/calendar'
import { es } from "date-fns/locale"



const preacherRoles = [
  { id: 1, name: 'Pastor' },
  { id: 2, name: 'Pastora' },
  { id: 3, name: 'Evangelista' },
  { id: 4, name: 'Profeta' },
  { id: 5, name: 'Supervisor' },
  { id: 6, name: 'Supervisora' },
]

const formSchema = z.object({
  name: z.string().min(1, { message: 'El nombre es requerido' }),
  preacher_role_id: z.number().optional(),
  thumb_id: z.string().optional(),
  // started_at: z.date({ message: 'La fecha de inicio es requerida' }),
  // ended_at: z.date({ message: 'La fecha de fin es requerida' }),
})


export default function NewEventForm() {
  const [isLoading, setIsLoading] = useState(false)

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: '',
      preacher_role_id: undefined,
      thumb_id: undefined,
      // started_at: new Date(),
      // ended_at: new Date(),
    },
  })

  const onSubmit = async (data: z.infer<typeof formSchema>) => {
    console.log("llega")
    console.log(data)
  }

  return (
    <div className="flex flex-col gap-4">
      <h1 className="text-2xl font-bold">Nueva Congreso/Evento</h1>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <FormField control={form.control} name="name" render={({ field }) => (
            <FormItem>
              <FormLabel>Nombre</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
            </FormItem>
          )} />
          <FormField control={form.control} name="description" render={({ field }) => (
            <FormItem>
              <FormLabel>Descripción</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
            </FormItem>
          )} />
          <FormField
            control={form.control}
            name="started_at"
            render={({ field }) => (
              <FormItem className="flex flex-col">
                <FormLabel>Fecha de inicio</FormLabel>
                <Popover>
                  <PopoverTrigger asChild>
                    <FormControl>
                      <Button
                        variant={"outline"}
                        className={cn(
                          "w-[240px] pl-3 text-left font-normal",
                          !field.value && "text-muted-foreground"
                        )}
                      >
                        {field.value ? (
                          format(field.value, "PPP", { locale: es })
                        ) : (
                          <span>Pick a date</span>
                        )}
                        <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                      </Button>
                    </FormControl>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0" align="start">
                    <Calendar
                      mode="single"
                      selected={field.value}
                      onSelect={field.onChange}
                      disabled={(date) =>
                        date > new Date() || date < new Date("2024-01-01")
                      }
                      captionLayout="dropdown"
                    />
                  </PopoverContent>
                </Popover>
                <FormDescription>
                  Fecha de inicio del evento/congreso.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="ended_at"
            render={({ field }) => (
              <FormItem className="flex flex-col">
                <FormLabel>Fecha de fin</FormLabel>
                <Popover>
                  <PopoverTrigger asChild>
                    <FormControl>
                      <Button
                        variant={"outline"}
                        className={cn(
                          "w-[240px] pl-3 text-left font-normal",
                          !field.value && "text-muted-foreground"
                        )}
                      >
                        {field.value ? (
                          format(field.value, "PPP", { locale: es })
                        ) : (
                          <span>Pick a date</span>
                        )}
                        <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                      </Button>
                    </FormControl>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0" align="start">
                    <Calendar
                      mode="single"
                      selected={field.value}
                      onSelect={field.onChange}
                      disabled={(date) =>
                        date > new Date() || date < new Date("1900-01-01")
                      }
                      captionLayout="dropdown"
                    />
                  </PopoverContent>
                </Popover>
                <FormDescription>
                  Fecha de finalización del evento/congreso.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
        </form>
        <Button type="submit" disabled={isLoading}>
          {isLoading ? 'Creando...' : 'Crear Congreso/Evento'}
        </Button>
      </Form>
    </div>
  )
}
