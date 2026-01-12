import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface VimeoProgresiveFile {
  link: string;
  link_expiration_time: string;
  rendition: string;
  width: number;
}

interface VimeoResponse {
  play?: {
    progressive?: VimeoProgresiveFile[];
  };
  error?: string;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  // "Access-Control-Allow-Headers": "Content-Type, Authorization
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { videoId } = await req.json();
    if (!videoId) {
      return createErrorResponse(
        "videoId es requerido",
        "MISSING_VIDEO_ID",
        400,
      );
    }

    // En Supabase local, usar las variables automáticas o el servicio interno
    // En producción, usar las variables personalizadas
    const accessToken = Deno.env.get("VIMEO_ACCESS_TOKEN");
    const baseURL = Deno.env.get("VIMEO_BASE_URL");

    if (!accessToken || !baseURL) {
      console.error(
        "Faltan variables de entorno: VIMEO_ACCESS_TOKEN, VIMEO_BASE_URL",
      );
      // throw new Error("Configuración de Vimeo incompleta");
      return createErrorResponse(
        "Error de configuración en el servidor. Faltan variables de entorno: VIMEO_ACCESS_TOKEN, VIMEO_BASE_URL",
        "CONFIG_ERROR",
        500,
      );
    }
    const url = `${baseURL}${videoId}?fields=play.progressive`;
    console.log(url);

    // Fetch con Timeout (Para evitar que la función se quede colgada)
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000); // 8 segundo de límite

    const response = await fetch(url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      signal: controller.signal,
    }).finally(() => clearTimeout(timeout));

    if (!response.ok) {
      const vimeoError = await response
        .json()
        .catch(() => ({ error: "Error desconocido de Vimeo" }));
      console.error(`Vimeo API Error [${response.status}]:`, vimeoError);

      const status = response.status === 404 ? 404 : 502; // 502 Bad Gateway si Vimeo falla
      return createErrorResponse(
        `Vimeo: ${vimeoError.error || "Video no disponible"}`,
        status === 404 ? "VIDEO_NOT_FOUND" : "VIMEO_API_ERROR",
        status,
      );
    }

    const data: VimeoResponse = await response.json();
    const files = data.play?.progressive;
    if (!files || files.length === 0) {
      return createErrorResponse(
        "Vimeo no ha procesado archivos para este video",
        "VIDEO_PROCESSING",
        422,
      );
    }
    const preferredQualities = ["1080p", "720p", "540p", "360p", "240p"];
    let selectedFile = files[0];
    for (const quality of preferredQualities) {
      const match = files.find((f) => f.rendition === quality);
      if (match) {
        selectedFile = match;
        break;
      }
    }

    return new Response(
      JSON.stringify({
        video_id: videoId,
        video_url: selectedFile.link,
        link_expiration_time: selectedFile.link_expiration_time,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    const isTimeout = error.name === "AbortError";
    console.error("Edge function Exception", error);

    return createErrorResponse(
      isTimeout
        ? "Tiempo de espera agotado con Vimeo"
        : "Error interno de la función",
      isTimeout ? "TIMEOUT" : "INTERNAL_ERROR",
      isTimeout ? 504 : 500,
    );
  }
});

function createErrorResponse(
  message: string,
  errorCode: string,
  status: number,
) {
  return new Response(
    JSON.stringify({ error: message, code: errorCode, success: false }),
    {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
}
