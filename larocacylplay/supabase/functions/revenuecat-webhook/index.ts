import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  // 🔐 Validar firma
  const authHeader = req.headers.get("authorization");
  if (authHeader !== `Bearer ${Deno.env.get("REVENUECAT_WEBHOOK_SECRET")}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const payload = await req.json();
  const event = payload?.event;

  if (!event?.id) {
    return new Response("Invalid payload", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 📦 Guardar evento (rápido)
  const { error } = await supabase
    .from("revenuecat_events")
    .insert({
      event_id: event.id,
      event_type: event.type,
      app_user_id: event.app_user_id,
      payload,
    });

  // Evento duplicado → OK igualmente
  if (error && error.code !== "23505") {
    console.error(error);
    return new Response("Error", { status: 500 });
  }

  // ✅ Responder 200 (rápido y seguro)
  return new Response("ok", { status: 200 });
});
