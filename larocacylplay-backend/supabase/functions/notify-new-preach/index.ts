import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2.39.7";
import { JWT } from "npm:google-auth-library@8.8.0";

type InsertPayload = {
  type: "INSERT";
  table: string;
  schema: string;
  record: CollectionItemRow;
  old_record: null;
};

type CollectionItemRow = {
  id: number;
  preach_id: number;
  collection_id: number;
};

type CollectionItem = {
  id: number;
  preach_id: number;
  collection_id: number;
};

type DeviceToken = {
  fcm_token: string;
  user_id: string;
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Función helper para dividir array en lotes
function chunkArray<T>(array: T[], chunkSize: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }
  return chunks;
}

serve(async (req) => {
  // 1. SEGURIDAD: Validar que la petición viene de nuestro sistema (Service Role)
  // const authHeader = req.headers.get("Authorization");
  const payload: InsertPayload = await req.json();
  const record = payload.record;
  console.log(payload);

  if (payload.type !== "INSERT") {
    return new Response("Skip: Not an insert", { status: 200 })
  }

  try {

    const [itemRes, tokenRes] = await Promise.all([
      supabase
        .from("collection_item")
        .select("preach_id(id, title), collection_id(id, title)")
        .eq("id", record.id)
        .single(),
      supabase
        .rpc(
          "get_tokens_for_collection_notification",
          { p_collection_id: record.collection_id }
        )
    ])
    if(itemRes.error || !itemRes.data) throw new Error('Preach details not found')
    if(tokenRes.error) throw new Error('Error fetching tokens via RPC')

    const tokens = tokenRes.data
    const item = itemRes.data as any

    if(!tokens || tokens.length === 0) {
      return new Response("No subscribers to notify", { status: 200 })
    }

    const notificationTitle = "¡Nueva predica disponible!"
    const notificationBody = `Se ha añadido ${item.preach_id.title} en la serie ${item.collection_id.title}`
    const notificationUrl = `larocaplayapp://collection/${item.collection_id.id}/preach/${item.preach_id.id}`

    const { data: notificationRecord, error: notificationError } = await supabase
      .from("notifications")
      .insert({
        title: notificationTitle,
        body: notificationBody,
        payload: payload
      })
      .select("id")
      .single();

    if (notificationError || !notificationRecord) {
      throw new Error(`Failed to create notification record: ${notificationError?.message || 'Unknown error'}`);
    }


    // 2. AUTH GOOGLE: Preparar el Access Token de Firebase
    const serviceAccount = JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!,
    );
    const client = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ["https://www.googleapis.com/auth/cloud-platform"],
    });

    const gTokens = await client.authorize();
    const accessToken = gTokens.access_token;
    
    if (!accessToken) {
      throw new Error('Failed to obtain Firebase access token');
    }
    
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

    const successUserIds: string[] = [];
    const invalidTokens: string[] = [];
    
    // 4. ENVÍO: Dividir tokens en lotes de 500 (límite de FCM)
    const FCM_BATCH_SIZE = 500;
    const tokenBatches = chunkArray(tokens as DeviceToken[], FCM_BATCH_SIZE);
    
    console.log(`Procesando ${tokens.length} tokens en ${tokenBatches.length} lotes`);

    // Función para enviar notificaciones de un lote
    const sendBatch = async (batch: DeviceToken[]) => {
      const batchResults = {
        successUserIds: [] as string[],
        invalidTokens: [] as string[],
      };

      // Enviar cada notificación del lote en paralelo
      const sendPromises = batch.map(async (device) => {
        const fcmPayload = {
          message: {
            token: device.fcm_token,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: {
              url: notificationUrl
            },
            // Configuración para Android
            android: {
              priority: "high",
              notification: {
                sound: "default",
                channelId: "default",
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
              },
            },
            // Configuración para iOS
            apns: {
              headers: {
                "apns-topic": "com.anceldev.LaRocaPlay",
                "apns-push-type": "alert",
                "apns-priority": "10",
              },
              payload: {
                aps: { 
                  sound: "default"
                },
              },
            },
          },
        };

        try {
          const res = await fetch(fcmUrl, {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(fcmPayload),
          });
          
          if (res.ok) {
            batchResults.successUserIds.push(device.user_id as string);
          } else {
            try {
              const errorData = await res.json();
              if (
                errorData.error?.status === "UNREGISTERED" || 
                errorData.error?.details?.[0]?.errorCode === "INVALID_ARGUMENT" ||
                errorData.error?.code === 404
              ) {
                batchResults.invalidTokens.push(device.fcm_token);
              } else {
                console.error(`Error sending to token ${device.fcm_token}:`, errorData);
              }
            } catch (jsonError) {
              console.error(`Error parsing error response for token ${device.fcm_token}:`, jsonError);
            }
          }
        } catch (e) {
          console.error(`Error sending to token ${device.fcm_token}:`, e);
        }
      });

      await Promise.all(sendPromises);
      return batchResults;
    };

    // Procesar todos los lotes en paralelo
    const batchResults = await Promise.all(tokenBatches.map(sendBatch));
    
    // Consolidar resultados de todos los lotes
    batchResults.forEach((result) => {
      successUserIds.push(...result.successUserIds);
      invalidTokens.push(...result.invalidTokens);
    });

    // Eliminar tokens inválidos de la base de datos
    if (invalidTokens.length > 0) {
      const { error: deleteError } = await supabase
        .from("user_devices")
        .delete()
        .in("fcm_token", invalidTokens);
      
      if (deleteError) {
        console.error("Error eliminando tokens inválidos: ", deleteError.message);
      } else {
        console.log(`Eliminados ${invalidTokens.length} tokens inválidos`);
      }
    }

    // Insertar registros de notificaciones para usuarios exitosos
    if(successUserIds.length > 0) {
      const userNotifInserts = successUserIds.map(uid => ({
        user_id: uid,
        notification_id: notificationRecord.id
      }));
      
      const { error } = await supabase
        .from("user_notifications")
        .insert(userNotifInserts);

      if(error) {
        console.error("Error en inserción masiva: ", error.message);
      }
    }

    return new Response(JSON.stringify({ 
      success: true,
      sent: successUserIds.length,
      invalidTokens: invalidTokens.length,
      total: tokens.length
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Function Error:", err instanceof Error ? err.message : String(err));
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
