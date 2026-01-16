// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

console.log("Hello from Functions!")

Deno.serve(async (req) => {
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // CLAVE MAESTRA
  )

  // 1. Obtener el usuario que hace la petición (vía JWT)
  const authHeader = req.headers.get('Authorization')!
  const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(authHeader.replace('Bearer ', ''))

  if (authError || !user) return new Response("No autorizado", { status: 401 })

  const userId = user.id

  // 2. Lógica de limpieza (Opcional: RevenueCat, Storage, etc.)
  // Ejemplo: await deleteUserInRevenueCat(userId)

  // 3. Borrar el usuario de la tabla auth.users
  const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(userId)

  if (deleteError) {
    return new Response(JSON.stringify({ error: deleteError.message }), { status: 500 })
  }

  return new Response(JSON.stringify({ message: "Usuario eliminado correctamente" }), { status: 200 })
})