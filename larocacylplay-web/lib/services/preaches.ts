// import { createClient } from "@/lib/supabase/client";
'use server'

import { createClient } from "../supabase/server";
import { Preach, ShortPreach } from "@/lib/types";

export async function getPreaches(): Promise<Preach[]> {
  const supabase = await createClient();
  const { data, error } = await supabase.from('preach').select('*');
  if (error) {
    throw error;
  }
  // return mapToPreach(data);
  return data as unknown as Preach[]
}
export async function createPreach({title, description, date, preacher_id, video_id}: {title: string, description?: string, date: Date, preacher_id: number, video_id: string}) {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("preach")
    .insert([{title, description, date, preacher_id, video_id}])
    .select("id")
    .single()
    if(error) {
      console.log(error)
      throw error
    }
    return data.id
}

export async function getPreach(preachId: number): Promise<ShortPreach> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('preach')
    .select('id, title, description, date, preacher(name, preacher_role_id(name))')
    .eq('id', preachId)
    .single()
  
  if(error) {
    console.error(error)
    throw error
  }
  console.log(data)
  return data as unknown as ShortPreach
}

export async function addPreachToCollection({preachId, collectionId, position}: {preachId: number, collectionId: number, position?: number}) {
  const supabase = await createClient()
  const { data, error } = await supabase
  .from("collection_item")
  .insert([
    {
      preach_id: preachId,
      collection_id: collectionId,
      position: position
    }
  ])
  if(error) {
    console.log(error)
    throw error
  }
  return true
}

export async function updatePreachPhoto(preachId: number, photoId: string): Promise<void> {
  const supabase = await createClient();
  console.log("PreachId: ", preachId)
  console.log("Photo id: ", photoId)
  
  const { data , error } = await supabase
  .from('preach')
  .update({ 'thumb_id': photoId })
  .select()
  .eq('id', preachId)
  .single()
  
  if (error) {
    console.log("Server error", error)
    throw error;
  }
  return data
}

// export async function createPreach({ title, date, video, description, preacher_id, serie_id, thumb_id, congress_id }: { title: string, date: Date, video: string, description?: string, preacher_id?: number, serie_id?: number, thumb_id?: string, congress_id?: number }): Promise<Preach> {
//   const supabase = await createClient();
  
//   const { data, error } = await supabase
//   .from('preaches')
//   .insert([{ title, date, video, description, preacher_id, serie_id, thumb_id, congress_id }])
//   .select()
//   .single();

//   if (error) {
//     throw error;
//   }
//   return { ...data, created_at: new Date(data.created_at) };
// }

// export function mapToPreach(data: any[]): Preach[] { // eslint-disable-line @typescript-eslint/no-explicit-any
//   return data.map(item => ({
//     id: item.id,
//     title: item.title,
//     description: item.description,
//     created_at: new Date(item.created_at),
//     date: new Date(item.date),
//     video: item.video,
//     serie_id: item.serie_id,
//     thumb_id: item.thumb_id,
//     congress_id: item.congress_id,
//     preacher_id: item.preacher_id,
//   }));
// }