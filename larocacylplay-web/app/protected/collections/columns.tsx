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
import { Collection } from "@/lib/types"
import Image from "next/image"
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card"

export const columns: ColumnDef<Collection>[] = [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "title",
    header: "Nombre",
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
            <Image src={`http://127.0.0.1:54321/storage/v1/object/public/app/collection/${row.original.image_id}`} alt={row.original.title} width={300} height={100} />
          </HoverCardContent>
        </HoverCard>
      )
    }

  },
  {
    accessorKey: "isPublic",
    header: "Público",
    cell: ({ row }) => {
      return row.original.is_public ? "Sí" : "No"
    }
  },
  {
    accessorKey: "collection_type_id",
    header: "Tipo",
    cell: ({ row }) => {
      return row.original.collection_type_id.name
    }
  },
  {
    id: "actions",
    header: "Acciones",
    cell: ({ row }) => {
      const collection = row.original
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
              <Link href={`/protected/collections/${collection.id}`}>Ver colección</Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Editar información</DropdownMenuItem>
            <DropdownMenuItem asChild>
              <Link href={`/protected/collections/add-collection-image/${collection.id}`}>Añadir foto</Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    }
  }
]