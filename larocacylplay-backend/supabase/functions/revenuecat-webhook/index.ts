/**
 * RevenueCat Webhook Handler
 * 
 * This function handles webhook events from RevenueCat and updates the subscriptions table.
 * 
 * Event Types Handled:
 * - INITIAL_PURCHASE: Creates/updates subscription with status "active"
 * - RENEWAL: Updates subscription, keeps status "active", updates expiration
 * - CANCELLATION: Updates status to "cancelled" (subscription still valid until expiration)
 * - UNCANCELLATION: Updates status back to "active"
 * - SUBSCRIPTION_PAUSED: Updates status to "cancelled" (won't renew)
 * - BILLING_ISSUE: Keeps status "active" (you may want to handle this differently)
 * - SUBSCRIPTION_EXTENDED: Updates expiration date, keeps status "active"
 * - EXPIRATION: Updates status to "expired"
 * 
 * Note: The findUserId function needs to be adjusted based on your schema.
 * It currently checks subscriptions table first, then users table.
 */

import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Tipado común para los payloads de RevenueCat
// RevenueCat webhook payload v1.0 (event envelope)
interface RevenueCatEventEnvelope {
  api_version: string; // e.g. "1.0"
  event: RevenueCatEvent;
}

// RevenueCat event body (matching docs example)
interface RevenueCatEvent {
  id: string; // UniqueIdentifierOfEvent
  type: string; // e.g. "INITIAL_PURCHASE"
  app_id: string;
  app_user_id: string; // yourCustomerAppUserID
  original_app_user_id: string;
  product_id: string;
  entitlement_id?: string | null;
  entitlement_ids?: string[];
  presented_offering_id?: string | null;
  store: string; // APP_STORE | PLAY_STORE | STRIPE | ...
  environment: string; // PRODUCTION | SANDBOX
  event_timestamp_ms: number;
  purchased_at_ms?: number;
  expiration_at_ms?: number;
  period_type?: string; // NORMAL | TRIAL | INTRO
  original_transaction_id?: string | null;
  transaction_id?: string | null;
  is_family_share?: boolean;
  offer_code?: string | null;
  price?: number;
  price_in_purchased_currency?: number;
  currency?: string;
  country_code?: string;
  commission_percentage?: number;
  tax_percentage?: number;
  takehome_percentage?: number;
  aliases?: string[];
  subscriber_attributes?: Record<
    string,
    {
      value: string;
      updated_at_ms?: number;
    }
  >;
  [key: string]: unknown;
}

interface RevenueCatWebhookPayload {
  event: RevenueCatEvent;
  api_version: string;
}

interface RevenueCatSubscriberResponse {
  request_date: string;
  request_date_ms: number;
  subscriber: RCSubscriber;
}

interface RCSubscriber {
  entitlements: Record<string, RCEntitlement>;
  first_seen: string;
  management_url: string | null;
  non_subscriptions: Record<string, RCPurchase[]>;
  original_app_user_id: string;
  original_application_version: string | null;
  original_purchase_date: string;
  other_purchases: Record<string, unknown>;
  subscriptions: Record<string, RCSubscription>;
}

interface RCEntitlement {
  expires_date: string | null;
  grace_period_expires_date: string | null;
  product_identifier: string;
  purchase_date: string;
}

interface RCPurchase {
  id: string;
  is_sandbox: boolean;
  purchase_date: string;
  store: string;
}

interface RCSubscription {
  auto_resume_date: string | null;
  billing_issues_detected_at: string | null;
  display_name: string;
  expires_date: string | null;
  grace_period_expires_date: string | null;
  is_sandbox: boolean;
  original_purchase_date: string;
  ownership_type: string;      // e.g. "PURCHASED", "FAMILY_SHARED"
  period_type: string;         // e.g. "normal", "trial", "intro"
  price: {
    amount: number,
    currency: string,
  }
  purchase_date: string;
  refunded_at: string | null;
  store: string;               // e.g. "app_store", "play_store", "promotional"
  store_transaction_id: string | number;
  unsubscribe_detected_at: string | null;
}

const rcResponseInitialPurchase = {
  "event": {
      "event_timestamp_ms": 1658726378679,
      "product_id": "rc_4999_1y_1w0",
      "period_type": "NORMAL",
      "purchased_at_ms": 1658726374000,
      "expiration_at_ms": 1658812774000,
      "environment": "SANDBOX",
      "entitlement_id": null,
      "entitlement_ids": [
          "pro"
      ],
      "presented_offering_id": null,
      "transaction_id": "123456789012345",
      "original_transaction_id": "123456789012345",
      "is_family_share": false,
      "country_code": "US",
      "app_user_id": "6894C16F-7467-44B2-9BB7-38AABA1A2261",
      "aliases": [
          "$RCAnonymousID:8069238d6049ce87cc529853916d624c"
      ],
      "original_app_user_id": "$RCAnonymousID:87c6049c58069238dce29853916d624c",
      "currency": "USD",
      "price": 4.99,
      "price_in_purchased_currency": 4.99,
      "subscriber_attributes": {
          "$email": {
              "updated_at_ms": 1662955084635,
              "value": "firstlast@gmail.com"
          }
      },
      "store": "APP_STORE",
      "takehome_percentage": 0.7,
      "tax_percentage": 0.0,
      "commission_percentage": 0.3,
      "offer_code": null,
      "type": "INITIAL_PURCHASE",
      "id": "12345678-1234-1234-1234-123456789012",
      "app_id": "proj58b05d2f",
      "experiments": [
          {
              "experiment_id": "prexp123",
              "experiment_variant": "b",
              "enrolled_at_ms": 1658726378679
          }
      ]
  },
  "api_version": "1.0"
}
const rcResponseRenewall = {
  "event": {
      "event_timestamp_ms": 1658726405017,
      "product_id": "com.subscription.weekly",
      "period_type": "NORMAL",
      "purchased_at_ms": 1658755132000,
      "expiration_at_ms": 1659359932000,
      "environment": "PRODUCTION",
      "entitlement_id": null,
      "entitlement_ids": [
          "pro"
      ],
      "presented_offering_id": null,
      "transaction_id": "123456789012345",
      "original_transaction_id": "123456789012345",
      "is_family_share": false,
      "country_code": "DE",
      "app_user_id": "1234567890",
      "aliases": [
          "$RCAnonymousID:8069238d6049ce87cc529853916d624c"
      ],
      "original_app_user_id": "$RCAnonymousID:87c6049c58069238dce29853916d624c",
      "currency": "EUR",
      "is_trial_conversion": false,
      "price": 8.14,
      "price_in_purchased_currency": 7.99,
      "subscriber_attributes": {
          "$email": {
              "updated_at_ms": 1662955084635,
              "value": "firstlast@gmail.com"
          }
      },
      "store": "APP_STORE",
      "takehome_percentage": 0.7,
      "tax_percentage": 0.0,
      "commission_percentage": 0.3,
      "offer_code": null,
      "type": "RENEWAL",
      "id": "12345678-1234-1234-1234-123456789012",
      "app_id": "1234567890",
      "experiments": [
          {
              "experiment_id": "prexp123",
              "experiment_variant": "b",
              "enrolled_at_ms": 1762274791000
          }
      ]
  },
  "api_version": "1.0"
}
const rcResponseCancellation = {
  "event": {
    "event_timestamp_ms": 1601337615995,
    "product_id": "com.revenuecat.myapp.weekly",
    "period_type": "NORMAL",
    "purchased_at_ms": 1601417766000,
    "expiration_at_ms": 1602022566000,
    "environment": "PRODUCTION",
    "entitlement_id": "pro",
    "entitlement_ids": [
      "pro"
    ],
    "presented_offering_id": "defaultoffering",
    "transaction_id": "100000000000002",
    "original_transaction_id": "100000000000000",
    "app_user_id": "$RCAnonymousID:12345678-1234-1234-1234-123456789123",
    "aliases": [
      "$RCAnonymousID:12345678-1234-ABCD-1234-123456789123",
      "user_1234"
    ],
    "offer_code": "free_month",
    "original_app_user_id": "$RCAnonymousID:12345678-1234-ABCD-1234-123456789123",
    "cancel_reason": "UNSUBSCRIBE",
    "currency": "USD",
    "price": 0.0,
    "price_in_purchased_currency": 0.0,
    "subscriber_attributes": {
      "$idfa": {
        "value": "12345678-1234-1234-1234-12345678912x",
        "updated_at_ms": 1578018408238
      },
      "$appsflyerId": {
        "value": "1234567891234-1234567",
        "updated_at_ms": 1578018408238
      },
      "favorite_food": {
        "value": "pizza",
        "updated_at_ms": 1578018408238
      }
    },
    "store": "APP_STORE",
    "takehome_percentage": 0.7,
    "tax_percentage": 0.0,
    "commission_percentage": 0.3,
    "type": "CANCELLATION",
    "id": "12345678-ABCD-1234-ABCD-12345678912",
    "experiments": [
      {
        "experiment_id": "prexp123",
        "experiment_variant": "b",
        "enrolled_at_ms": 1762274791000
      }
    ]
  },
  "api_version": "1.0"
}
const rcResponseUncancellation = {
  "event": {
    "event_timestamp_ms": 1601337615995,
    "product_id": "com.revenuecat.myapp.weekly",
    "period_type": "NORMAL",
    "purchased_at_ms": 1601417766000,
    "expiration_at_ms": 1602022566000,
    "environment": "PRODUCTION",
    "entitlement_id": "pro",
    "entitlement_ids": [
      "pro"
    ],
    "presented_offering_id": "defaultoffering",
    "transaction_id": "100000000000002",
    "original_transaction_id": "100000000000000",
    "app_user_id": "$RCAnonymousID:12345678-1234-1234-1234-123456789123",
    "aliases": [
      "$RCAnonymousID:12345678-1234-ABCD-1234-123456789123",
      "user_1234"
    ],
    "offer_code": "free_month",
    "original_app_user_id": "$RCAnonymousID:12345678-1234-ABCD-1234-123456789123",
    "cancel_reason": "UNSUBSCRIBE",
    "currency": "USD",
    "price": 0.0,
    "price_in_purchased_currency": 0.0,
    "subscriber_attributes": {
      "$idfa": {
        "value": "12345678-1234-1234-1234-12345678912x",
        "updated_at_ms": 1578018408238
      },
      "$appsflyerId": {
        "value": "1234567891234-1234567",
        "updated_at_ms": 1578018408238
      },
      "favorite_food": {
        "value": "pizza",
        "updated_at_ms": 1578018408238
      }
    },
    "store": "APP_STORE",
    "takehome_percentage": 0.7,
    "tax_percentage": 0.0,
    "commission_percentage": 0.3,
    "type": "CANCELLATION",
    "id": "12345678-ABCD-1234-ABCD-12345678912",
    "experiments": [
      {
        "experiment_id": "prexp123",
        "experiment_variant": "b",
        "enrolled_at_ms": 1762274791000
      }
    ]
  },
  "api_version": "1.0"
}
const rcResponseSubscriptionPaused = {
  "event": {
      "event_timestamp_ms": 1652796516000,
      "product_id": "premium",
      "period_type": "NORMAL",
      "purchased_at_ms": 1652681048845,
      "expiration_at_ms": 1655366648845,
      "environment": "PRODUCTION",
      "entitlement_id": "Premium1",
      "entitlement_ids": [
          "Premium1"
      ],
      "presented_offering_id": "premium",
      "transaction_id": "123456789012345",
      "original_transaction_id": "123456789012345",
      "is_family_share": false,
      "country_code": "US",
      "app_user_id": "1234567890",
      "aliases": [
          "$RCAnonymousID:8069238d6049ce87cc529853916d624c"
      ],
      "original_app_user_id": "$RCAnonymousID:87c6049c58069238dce29853916d624c",
      "auto_resume_at_ms": 1657951448845,
      "currency": "USD",
      "price": 0.0,
      "price_in_purchased_currency": 0.0,
      "subscriber_attributes": {
          "$email": {
              "updated_at_ms": 1662955084635,
              "value": "firstlast@gmail.com"
          }
      },
      "store": "PLAY_STORE",
      "takehome_percentage": 0.85,
      "tax_percentage": 0.0,
      "commission_percentage": 0.15,
      "offer_code": null,
      "type": "SUBSCRIPTION_PAUSED",
      "id": "12345678-1234-1234-1234-123456789012",
      "app_id": "1234567890",
      "experiments": [
          {
              "experiment_id": "prexp123",
              "experiment_variant": "b",
              "enrolled_at_ms": 1762274791000
          }
      ]
  },
  "api_version": "1.0"
}
const rcResponseBillingIssue = {
  "event" : {
    "event_timestamp_ms" : 1601337601013,
    "product_id" : "com.revenuecat.myapp.monthly",
    "period_type" : "NORMAL",
    "purchased_at_ms" : 1598640647000,
    "expiration_at_ms" : 1601319047000,
    "environment" : "PRODUCTION",
    "entitlement_id" : "pro",
    "entitlement_ids" : [
      "pro"
    ],
    "presented_offering_id" : "defaultoffering",
    "transaction_id" : "100000000000002",
    "original_transaction_id" : "100000000000000",
    "app_user_id" : "$RCAnonymousID:12345678-1234-1234-1234-123456789123",
    "aliases" : [
      "$RCAnonymousID:12345678-1234-1234-1234-123456789123"
    ],
    "offer_code": "summer_special",
    "original_app_user_id" : "$RCAnonymousID:12345678-1234-1234-1234-123456789123",
    "currency" : "USD",
    "price" : 0,
    "price_in_purchased_currency" : 0,
    "subscriber_attributes" : {
      "$idfa" : {
        "value" : "12345678-1234-1234-1234-12345678912x",
        "updated_at_ms" : 1578018408238
      },
      "$appsflyerId" : {
        "value" : "1234567891234-1234567",
        "updated_at_ms" : 1578018408238
      }
    },
    "store" : "APP_STORE",
    "takehome_percentage" : 0.7,
    "tax_percentage": 0.0,
    "commission_percentage": 0.3,
    "type" : "BILLING_ISSUE",
    "id" : "12345678-1234-1234-1234-12345678912",
    "experiments": [
      {
        "experiment_id": "prexp123",
        "experiment_variant": "b",
        "enrolled_at_ms": 1762274791000
      }
    ]
  },
  "api_version" : "1.0"
}
const rcResponseSubscriptionExtended = {
  "event": {
    "event_timestamp_ms": 1697451462232,
    "product_id": "com.subscription.weekly",
    "period_type": "NORMAL",
    "purchased_at_ms": 1696846623000,
    "expiration_at_ms": 1697451423000,
    "environment": "PRODUCTION",
    "entitlement_id": null,
    "entitlement_ids": ["pro"],
    "presented_offering_id": null,
    "transaction_id": "123456789012345",
    "original_transaction_id": "123456789012345",
    "is_family_share": false,
    "country_code": "US",
    "app_user_id": "1234567890",
    "aliases": ["$RCAnonymousID:8069238d6049ce87cc529853916d624c"],
    "original_app_user_id": "$RCAnonymousID:8069238d6049ce87cc529853916d624c",
    "currency": "USD",
    "price": 0.00,
    "price_in_purchased_currency": 0.00,
    "subscriber_attributes": {
        "$email": {
            "updated_at_ms": 1662955084635,
            "value": "firstlast@gmail.com"
        }
    },
    "store": "APP_STORE",
    "takehome_percentage": 0.7,
    "offer_code": null,
    "tax_percentage": 0.012,
    "commission_percentage": 0.3,
    "type": "SUBSCRIPTION_EXTENDED",
    "id": "12345678-1234-1234-1234-123456789012",
    "app_id": "1234567890",
    "experiments": [
        {
            "experiment_id": "prexp123",
            "experiment_variant": "b",
            "enrolled_at_ms": 1762274791000
        }
    ]
  },
  "api_version": "1.0"
}
const rcResponseExpiration = {
  "event": {
    "event_timestamp_ms": 1697451462232,
    "product_id": "com.subscription.weekly",
    "period_type": "NORMAL",
    "purchased_at_ms": 1696846623000,
    "expiration_at_ms": 1697451423000,
    "environment": "PRODUCTION",
    "entitlement_id": null,
    "entitlement_ids": ["pro"],
    "presented_offering_id": null,
    "transaction_id": "123456789012345",
    "original_transaction_id": "123456789012345",
    "is_family_share": false,
    "country_code": "US",
    "app_user_id": "1234567890",
    "aliases": ["$RCAnonymousID:8069238d6049ce87cc529853916d624c"],
    "original_app_user_id": "$RCAnonymousID:8069238d6049ce87cc529853916d624c",
    "expiration_reason": "UNSUBSCRIBE",
    "currency": "USD",
    "price": 0.00,
    "price_in_purchased_currency": 0.00,
    "subscriber_attributes": {
        "$email": {
            "updated_at_ms": 1662955084635,
            "value": "firstlast@gmail.com"
        }
    },
    "store": "APP_STORE",
    "takehome_percentage": 0.7,
    "offer_code": null,
    "tax_percentage": 0.012,
    "commission_percentage": 0.3,
    "type": "EXPIRATION",
    "id": "12345678-1234-1234-1234-123456789012",
    "app_id": "1234567890",
    "experiments": [
      {
        "experiment_id": "prexp123",
        "experiment_variant": "b",
        "enrolled_at_ms": 1762274791000
      }
    ]
  },
  "api_version": "1.0"
}

serve(async (req) => {
  // 🔐 Validar firma
  console.log("Recibiendo evento")
  const authHeader = req.headers.get("authorization");
  if (authHeader !== `Bearer ${Deno.env.get("REVENUECAT_WEBHOOK_SECRET")}`) {
    console.error("Los AuthToken no coincide")
    return new Response("Unauthorized", { status: 200 });
  }

  let payload;
  try {
    // const payloadData = await req.json();
    // const event: RevenueCatEventEnvelope = JSON.parse(payloadData)
    // console.log("Event payload: ", event)
    const rawBody = await req.text();
    console.log("Raw payload:", rawBody);
    const envelope = JSON.parse(rawBody) as RevenueCatEventEnvelope;
    console.log("Envelope: ", envelope)
    payload = envelope;
    const eventPayload: RevenueCatEvent = envelope.event;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    console.log("Trying to insert event")
    const { data: insertedVent, error: errorEvent } = await supabase
    .from("revenuecat_event")
    .insert({
      event_id: eventPayload.id,
      event_type: eventPayload.type,
      app_user_id: eventPayload.app_user_id,
      payload: eventPayload
    })
    .select("id")
    
    if(errorEvent) {
      console.log(errorEvent)
      if(errorEvent.code === "23505") {
        console.log("Evento duplicado, ya procesado:", payload.id);
        return new Response('ok', { status: 200});
      }
      console.log((`Error insertando evento: ${errorEvent}`))
      return new Response('ok', { status: 200 })
    }
    console.log("Inserted event:", insertedVent);

    
    const rcApiKey = Deno.env.get("RC_API_KEY");
    const url = `${Deno.env.get("RC_API_BASE_URL")}/subscribers/${eventPayload.app_user_id}`;
    
    console.log(rcApiKey)
    console.log(eventPayload.app_user_id)
    console.log(url)

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${rcApiKey}`,
        'X-Is-Sandbox': 'true',
      }
    })

    // console.log(await response.json());
    if (response.status !== 200) {
      console.log("Error, no se pudo encontrar un cliente con ese ID")
      return new Response("ok", { status: 200 });
    }
    const customer: RevenueCatSubscriberResponse = await response.json()
    console.log('Customer is: ', customer)

    const subscriber = customer.subscriber;
    const userId = payload.rc_app_user_id;
    const entitlements = Object.entries(subscriber.entitlements);

    for (const [entitlementId, entData] of entitlements) {
      const productId = entData.product_identifier;
      const subsData = subscriber.subscriptions[productId];
      console.log("Añadiendo: ", subsData)
      const { error } = await supabase
      .from('subscription')
      .upsert({
        user_id: eventPayload.app_user_id,
        rc_app_user_id: eventPayload.app_user_id,
        rc_entitlement_id: entitlementId,
        rc_product_id: productId,
        rc_product_display_name: subsData.display_name,
        rc_store: subsData.store,
        // plan_type: productId.includes('1y') ? 'yearly' : 'monthly',
        period_type: subsData.period_type,
        is_active: new Date(entData.expires_date!) > new Date(),
        is_sandbox: subsData.is_sandbox,
        purchase_date: entData.purchase_date,
        expires_date: entData.expires_date,
        grace_period_expires_date: entData.grace_period_expires_date,
        price_amount: subsData.price?.amount,
        price_currency: subsData.price?.currency
      }, {
        // Esto evita duplicados: si el usuario cambia de producto, 
        // se creará una nueva fila por el Unique(rc_app_user_id, rc_product_id)
        onConflict: 'rc_app_user_id, rc_product_id' 
      });
      if(error) {
        console.log("Error añadiendo subscripción", error)
      }
    }
    return new Response("ok", { status: 200 });

  } catch (error) {
    console.error("Error parsing JSON payload:", error);
    // Siempre responder 200 a RevenueCat
    return new Response("ok", { status: 200 });
  }
});

