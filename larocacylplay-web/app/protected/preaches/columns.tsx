"use client"

import { ColumnDef } from "@tanstack/react-table"
import { MoreHorizontal } from "lucide-react"
 
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import Link from "next/link"
import { Preach } from "@/lib/types"
import Image from "next/image"
import { format } from "date-fns"
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card"

export const columns: ColumnDef<Preach>[] = [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "title",
    header: "Nombre",
  },
  {
    accessorKey: "preacher.name",
    header: "Predicador",
    cell: ({ row }) => {
      const preacher = row.original.preacher
      return `${preacher.preacher_role_id.name} ${preacher.name}`
    }

  },
  {
    accessorKey: "image_id",
    header: "Imagen",
    cell: ({ row }) => {
      const image_id = row.original.image_id
      return (
        <HoverCard>
          <HoverCardTrigger className="underline">{image_id}</HoverCardTrigger>
          <HoverCardContent>
          <Image src={`http://127.0.0.1:54321/storage/v1/object/public/app/preach/${row.original.image_id}`} alt={row.original.title} width={300} height={100} />
          </HoverCardContent>
        </HoverCard>
      )
    }
  },
  {
    accessorKey: "date",
    header: "Fecha",
    cell: ({ row }) => {
      return format(row.original.date, "dd/MM/yyyy")
    }
  },
  {
    id: "actions",
    header: "Acciones",
    cell: ({ row }) => {
      const preach = row.original
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0">
              <span className="sr-only">Abrir menú</span>
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>Opciones</DropdownMenuLabel>
            <DropdownMenuItem>
              <Link href={`/protected/collections/preaches/${preach.id}`}>Ver colección</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Editar información</DropdownMenuItem>
            <DropdownMenuItem asChild>
              <Link href={`/protected/preaches/add-preach-thumb/${preach.id}`}>Añadir foto</Link>
            </DropdownMenuItem>
            <DropdownMenuItem asChild>
              <Link href={`/protected/preaches/add-to-collection/${preach.id}`}>Añadir a una colección</Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    }
  }
]