import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface VimeoProgresiveFile {
  link: string;
  link_expiration_time: string;
  rendition: string;
}

interface VimeoResponse {
  play?: {
    progressive?: VimeoProgresiveFile[];
  };
}

serve(async (req) => {
  try {
    const { videoId } = await req.json();

    if (!videoId) {
      return new Response(JSON.stringify({ error: "videoId es requerido" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }
    // ─────────────────────────────────────
    // Supabase client
    // ─────────────────────────────────────
    // En Supabase local, usar las variables automáticas o el servicio interno
    // En producción, usar las variables personalizadas
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!    
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    
    const supabase = createClient(
      supabaseUrl,
      supabaseKey
    );

    // ─────────────────────────────────────
    // 1️⃣ Buscar en cache
    // link válido si expira en al menos 1h (queda mínimo 2h de vida)
    // ─────────────────────────────────────
    // const now = new Date();
    // const oneHourFromNow = new Date(now.getTime() + 60 * 60 * 2000);

    // console.log("Buscando en cache de supabase...")
    // // console.log("Ahora:", now.toISOString())
    // // console.log("Mínimo de expiración (1h desde ahora):", oneHourFromNow.toISOString())

    // const { data: cachedVideo, error: cacheError } = await supabase
    //   .from("video_temporal_link")
    //   .select("video_id, link, link_expiration_time")
    //   .eq("video_id", videoId)
    //   .gte("link_expiration_time", oneHourFromNow.toISOString())
    //   .order("link_expiration_time", { ascending: false })
    //   .limit(1)
    //   .maybeSingle();

    // if (cacheError) {
    //   console.error("Cache error:", cacheError);
    // }

    // if (cachedVideo) {
    //     console.log("Encontrado en cache, devolviendo desde sb cache")
    //   // ✅ Cache hit
    //   console.log(cachedVideo)
    //   return new Response(
    //     // JSON.stringify({ video_id: cachedVideo.video_id, link: cachedVideo.video_link, link_expiration_time: cachedVideo.link_expiration_time }),
    //     JSON.stringify(cachedVideo),
    //     { status: 200, headers: { "Content-Type": "application/json" } }
    //   );
    // }

    // ─────────────────────────────────────
    // 2️⃣ Cache miss → Vimeo
    // ─────────────────────────────────────

    const accessToken = Deno.env.get("VIMEO_ACCESS_TOKEN");
    const baseURL = Deno.env.get("VIMEO_BASE_URL");

    if (!accessToken || !baseURL) {
      throw new Error("Configuración de Vimeo incompleta");
    }

    const url = `${baseURL}${videoId}`;
    // console.log("URL:", url)
    console.log("Obteniendo enlace de Vimeo")
    const response = await fetch(url, {
      method: 'GET',
      headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
      },
    });

    if(response.status !== 200) {
      const errorText = await response.text();
      console.error('Vimeo API Error: ');
      console.error('Status Code:', response.status);
      console.error('Response Body', errorText);
      return new Response(
        JSON.stringify({
        error: 'Video access denied',
        statusCode: response.status,
        details: errorText
      }),
      {
          status: response.status,
          headers: {'Content-Type': 'application/json'}
      });
    }

    const data: VimeoResponse = await response.json();

    if (!data.play?.progressive?.length) {
      return new Response(
        JSON.stringify({ error: "No hay links progresivos" }),
        { status: 404 }
      );
    }

    // Elegimos la mejor calidad disponible
    const qualities = ["720p", "540p", "360p", "240p"];
    let selected = data.play.progressive[0];

    for (const q of qualities) {
      const found = data.play.progressive.find(f => f.rendition === q);
      if (found) {
        selected = found;
        break;
      }
    }
    // console.log('Guardando en sb cache')
    // // ─────────────────────────────────────
    // // 3️⃣ Guardar en cache
    // // ─────────────────────────────────────

    // const {data: savedVideo, error: saveError} = await supabase
    // .from("video_temporal_link")
    // .insert({
    //   video_id: videoId,
    //   video_link: selected.link,
    //   link_expiration_time: selected.link_expiration_time,
    // })
    // .select()
    // if(saveError) {
    //   console.log("Save errors:", saveError)
    // }
    // console.log("Guardado en cache")
    // console.log("Devolviendo video")
    // ─────────────────────────────────────
    // 4️⃣ Responder solo el link
    // ─────────────────────────────────────
    return new Response(
      JSON.stringify({ video_id: videoId, video_url: selected.link, link_expiration_time: selected.link_expiration_time }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error en la función:", error);
    return new Response(
      JSON.stringify({ error: error.message ?? "Error interno" }),
      { status: 500 }
    );
  }
});
