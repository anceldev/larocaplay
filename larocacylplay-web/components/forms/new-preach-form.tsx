// 'use client'

// import React, { useState } from 'react'
// import z from 'zod'
// import { zodResolver } from '@hookform/resolvers/zod'
// import { useForm } from 'react-hook-form'
// import { Button } from '@/components/ui/button'
// import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
// import { Input } from '@/components/ui/input'
// import { format } from "date-fns"
// import {
//   Select,
//   SelectContent,
//   SelectItem,
//   SelectTrigger,
//   SelectValue,
// } from "@/components/ui/select"
// import { es } from "date-fns/locale"
// import { Preacher, Series, Event } from '@/lib/types'
// import { Popover, PopoverContent, PopoverTrigger } from '../ui/popover'
// import { cn } from '@/lib/utils'
// import { CalendarIcon } from 'lucide-react'
// import { Calendar } from '../ui/calendar'
// import { toast } from 'sonner'
// import { createPreach } from '@/lib/services/preaches'

// const formSchema = z.object({
//   title: z.string().min(1, { message: 'El título es requerido' }),
//   description: z.string().optional(),
//   preacher_id: z.number().optional(),
//   date: z.date({ message: 'La fecha es requerida' }),
//   video: z.url({ message: 'El video es requerido' }),
//   serie_id: z.number().optional(),
//   thumb_id: z.string().optional(),
//   congress_id: z.number().optional(),
// })

// export default function NewPreachForm({ preachers, series, events }: { preachers: Preacher[], series: Series[], events: Event[] }) {
//   const [isLoading, setIsLoading] = useState(false)

//   const form = useForm<z.infer<typeof formSchema>>({
//     resolver: zodResolver(formSchema),
//     defaultValues: {
//       title: '',
//       description: '',
//       preacher_id: undefined,
//       date: new Date(),
//       video: '',
//       serie_id: undefined,
//       thumb_id: undefined,
//       congress_id: undefined,
//     },
//   })

//   const onSubmit = async (data: z.infer<typeof formSchema>) => {
//     try {
//       setIsLoading(true)
//       const preach = await createPreach({
//         title: data.title,
//         date: data.date,
//         video: data.video,
//         description: data.description,
//         preacher_id: data.preacher_id,
//       })
//       console.log('Predicación creada:', preach)
//       toast.success('Predicación creada correctamente')
//       form.reset()
//       setIsLoading(false)
//       form.reset()
//     } catch (error) {
//       console.error('Error al crear predicación:', error)
//       toast.error('Error al crear la predicación. Inténtalo de nuevo.')
//       setIsLoading(false)
//     }
//     console.log("llega")
//     console.log(data)
//   }

//   return (
//     <div className="flex flex-col gap-4">
//       <h1 className="text-2xl font-bold">Nueva predicación</h1>
//       <Form {...form}>
//         <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
//           <div className="flex flex-col gap-4">
//             {/** title */}
//             <FormField control={form.control} name="title" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Título</FormLabel>
//                 <FormControl>
//                   <Input {...field} />
//                 </FormControl>
//               </FormItem>
//             )} />
//             {/** description */}
//             <FormField control={form.control} name="description" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Descripción</FormLabel>
//                 <FormControl>
//                   <Input {...field} />
//                 </FormControl>
//               </FormItem>
//             )} />
//             {/** preacher_id */}
//             <FormField control={form.control} name="preacher_id" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Predicador</FormLabel>
//                 <FormControl>
//                   <Select
//                     value={field.value?.toString()}
//                     onValueChange={(value) => field.onChange(parseInt(value))}
//                   >
//                     <SelectTrigger>
//                       <SelectValue placeholder="Selecciona un predicador" />
//                     </SelectTrigger>
//                     <SelectContent>
//                       {preachers.map((preacher) => (
//                         <SelectItem key={preacher.id} value={preacher.id.toString()}>
//                           {preacher.role} {preacher.name}
//                         </SelectItem>
//                       ))}
//                     </SelectContent>
//                   </Select>
//                 </FormControl>
//               </FormItem>
//             )} />
//             {/** date */}
//             <FormField
//               control={form.control}
//               name="date"
//               render={({ field }) => (
//                 <FormItem className="flex flex-col">
//                   <FormLabel>Fecha</FormLabel>
//                   <Popover>
//                     <PopoverTrigger asChild>
//                       <FormControl>
//                         <Button
//                           variant={"outline"}
//                           className={cn(
//                             "w-[240px] pl-3 text-left font-normal",
//                             !field.value && "text-muted-foreground"
//                           )}
//                         >
//                           {field.value ? (
//                             format(field.value, "PPP", { locale: es })
//                           ) : (
//                             <span>Pick a date</span>
//                           )}
//                           <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
//                         </Button>
//                       </FormControl>
//                     </PopoverTrigger>
//                     <PopoverContent className="w-auto p-0" align="start">
//                       <Calendar
//                         mode="single"
//                         selected={field.value}
//                         onSelect={field.onChange}
//                         disabled={(date) =>
//                           date > new Date() || date < new Date("1900-01-01")
//                         }
//                         captionLayout="dropdown"
//                       />
//                     </PopoverContent>
//                   </Popover>
//                   <FormDescription>
//                     Your date of birth is used to calculate your age.
//                   </FormDescription>
//                   <FormMessage />
//                 </FormItem>
//               )}
//             />
//              {/** video */}
//              <FormField control={form.control} name="video" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Video URL</FormLabel>
//                 <FormControl>
//                   <Input {...field} />
//                 </FormControl>
//               </FormItem>
//             )} />
//             {/** serie_id */}
//             { series.length > 0 && (
//             <FormField control={form.control} name="serie_id" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Serie</FormLabel>
//                 <FormControl>
//                   <Select 
//                     value={field.value?.toString()} 
//                     onValueChange={(value) => field.onChange(parseInt(value))}
//                   >
//                     <SelectTrigger>
//                       <SelectValue placeholder="Selecciona una serie" />
//                     </SelectTrigger>
//                     <SelectContent>
//                       {series.map((serie) => (
//                         <SelectItem key={serie.id} value={serie.id.toString()}>
//                           {serie.name}
//                         </SelectItem>
//                       ))}
//                     </SelectContent>
//                   </Select>
//                 </FormControl>
//               </FormItem>
//             )} />
//           )}
//           { events.length > 0 && (
//             <FormField control={form.control} name="congress_id" render={({ field }) => (
//               <FormItem>
//                 <FormLabel>Congreso</FormLabel>
//                 <FormControl>
//                   <Select 
//                     value={field.value?.toString()} 
//                     onValueChange={(value) => field.onChange(parseInt(value))}
//                   >
//                     <SelectTrigger>
//                       <SelectValue placeholder="Selecciona un congreso" />
//                     </SelectTrigger>
//                     <SelectContent>
//                       {events.map((event) => (
//                         <SelectItem key={event.id} value={event.id.toString()}>
//                           {event.name}
//                         </SelectItem>
//                       ))}
//                     </SelectContent>
//                   </Select>
//                 </FormControl>
//               </FormItem>
//             )} />
//           )}
           
//           </div>

//           <Button type="submit">
//             {isLoading ? 'Creando...' : 'Crear Predicación'}
//           </Button>
//         </form>

//       </Form>
//     </div>
//   )
// }
