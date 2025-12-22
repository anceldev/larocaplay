import { createClient } from "@/lib/supabase/server";
import { Event } from "@/lib/types";

export async function getEvents(): Promise<Event[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('congresses').select('*');
  if (error) {
    throw error;
  }
  return mapToEvent(data);
}

export function mapToEvent(data: any[]): Event[] { // eslint-disable-line @typescript-eslint/no-explicit-any
  return data.map(item => ({
    id: item.id,
    name: item.name,
    description: item.description,
    created_at: new Date(item.created_at),
    started_at: new Date(item.started_at),
    ended_at: new Date(item.ended_at),
    thumb_id: item.thumb_id,
  }));
}