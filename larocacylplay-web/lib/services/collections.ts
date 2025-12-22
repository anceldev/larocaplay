"use server"
import { createClient } from "@/lib/supabase/server";
import { Preach, PreachCollection } from "@/lib/types";


export async function getPreachCollections(): Promise<PreachCollection[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('preach_collection').select('id, title, description, thumb_id, is_public, collection_type_id(id, name), created_at, updated_at, ended_at');
  if (error) {
    throw error;
  }
  return data as unknown as PreachCollection[];
}

export async function getPreachesForCollection(collectionId: number): Promise<Preach[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('preach_collection_membership')
  .select('preach:preach_id (id, title, description, date, video_url, preacher:preacher_id(id, name, preacher_role_id(id, name), thumb_id))')
  .eq('collection_id', collectionId)
  .order('preach(date)', { ascending: true })

  // console.log("The data is", data)

  if (error) {
    throw error;
  }

  const mappedPreaches = data.map((item) => item.preach);
  // console.log(mappedPreaches)
  // return []
  return mappedPreaches as unknown as Preach[];
}

export async function updateCollectionPhoto(collectionId: number, photoId: string): Promise<void> {
  const supabase = await createClient();
  const { data , error } = await supabase.from('preach_collection').update({ 'thumb_id': photoId }).eq('id', collectionId)
  if (error) {
    console.log("Server error", error)
    throw error;
  }
}