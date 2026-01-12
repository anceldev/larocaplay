"use server"
import { createClient } from "@/lib/supabase/server";
import { Preach, Collection, ShortCollection } from "@/lib/types";


export async function getPreachCollections(): Promise<Collection[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('collection').select('id, title, description, image_id, is_public, collection_type_id(id, name), created_at, updated_at, ended_at');
  if (error) {
    throw error;
  }
  console.log(data)
  return data as unknown as Collection[];
}

export async function getShortCollections(): Promise<ShortCollection[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
  .from('collection')
  .select('id, title, description');
  if (error) {
    throw error;
  }
  return data as unknown as Collection[];
}
export async function getShortCollection(collection_id: number): Promise<ShortCollection> {
  const supabase = await createClient();
  const { data, error } = await supabase
  .from('collection')
  .select('id, title, description')
  .eq('id', collection_id)
  .single()
  if (error) {
    throw error;
  }
  return data as unknown as ShortCollection;
}

export async function getPreachesForCollection(collectionId: number): Promise<Preach[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('collection_item')
  .select('preach:preach_id (id, title, description, date, image_id,video_id, preacher:preacher_id(id, name, preacher_role_id(id, name), image_id))')
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
  const { data , error } = await supabase.from('collection').update({ 'image_id': photoId }).eq('id', collectionId)
  if (error) {
    console.log("Server error", error)
    throw error;
  }
}
export async function createCollection({title, description, image_id, is_public, is_home_screen, collection_type_id, created_at}: {title: string, description?: string, image_id?: string, is_public: boolean, is_home_screen: boolean, collection_type_id: number, created_at: Date}) {
  const supabase = await createClient();
  const { data, error } = await supabase
  .from('collection')
  .insert({
    title: title,
    description: description,
    image_id: image_id,
    is_public: is_public,
    is_home_screen: is_home_screen,
    collection_type_id: collection_type_id,
    created_at: created_at,
  })
  .select("id")
  .single()
  if (error) {
    console.log("Server error", error)
    throw error;
  }
  return true
}