"use client"

import { Badge } from "@/components/ui/badge"
import { preacherRoles } from "@/lib/constants"
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
import { PreachCollection } from "@/lib/types"

export const columns: ColumnDef<PreachCollection>[] = [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "title",
    header: "Nombre",
  },
  {
    accessorKey: "thumb_id",
    header: "Imagen"

  },
  {
    accessorKey: "isPublic",
    header: "Público",
    cell: ({ row }) => {
      return row.original.isPublic ? "Sí" : "No"
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
              <Link href={`/protected/collections/add-collection-photo/${collection.id}`}>Añadir foto</Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    }
  }
]