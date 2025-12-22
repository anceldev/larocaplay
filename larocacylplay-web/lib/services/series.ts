import { createClient } from "@/lib/supabase/client";
import { Series } from "@/lib/types";

export async function getSeries(): Promise<Series[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('series').select('*');
  if (error) {
    throw error;
  }
  return mapToSeries(data);
}
export async function createSeries({name, description}: {name: string, description?: string}): Promise<Series> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('series').insert({name, description}).select().single();
  if (error) {
    throw error;
  }
  return {
    ...data,
    created_at: new Date(data.created_at)
  };
}

export function mapToSeries(data: any[]): Series[] { // eslint-disable-line @typescript-eslint/no-explicit-any
  return data.map(item => ({
    id: item.id,
    name: item.name,
    description: item.description,
    thumb_id: item.thumb_id,
    created_at: new Date(item.created_at),
    preaches: item.preaches ?? [],
  }));
}