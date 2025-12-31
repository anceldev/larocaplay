"use client"

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
import { Preacher } from "@/lib/types"

export const columns: ColumnDef<Preacher>[] = [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "name",
    header: "Nombre",
  },
  {
    accessorKey: "preacher_role_id",
    header: "Rol",
    cell: ({ row }) => {
      const role = preacherRoles.find(role => role.id === row.original.preacher_role_id.id)
      return role?.name
    }
  },
  {
    accessorKey: "thumb_id",
    header: "Imagen",
  },
  {
    id: "actions",
    header: "Acciones",
    cell: ({ row }) => {
      const preacher = row.original
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
            <DropdownMenuItem
              // onClick={() => navigator.clipboard.writeText(payment.id)}
            >
              Ver información
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Editar información</DropdownMenuItem>
            <DropdownMenuItem asChild>
              <Link href={`/protected/preachers/add-preacher-photo/${preacher.id}`}>Añadir foto</Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    }
  }
]