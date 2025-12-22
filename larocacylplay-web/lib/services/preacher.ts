'use server'

import { createClient } from "@/lib/supabase/server";
import { Preacher, PreacherRole } from "@/lib/types";

export async function getPreachers(): Promise<Preacher[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
  .from('preacher')
  .select('id, name, preacher_role_id(id, name), thumb_id, created_at');
  if (error) {
    throw error;
  }
  return data as unknown as Preacher[];
}

export async function updatePreacherPhoto(preacherId: number, photoId: string): Promise<void> {
  const supabase = await createClient();
  const { data , error } = await supabase.from('preacher').update({ 'thumb_id': photoId }).eq('id', preacherId)
  if (error) {
    console.log("Server error", error)
    throw error;
  }
}
export async function createNewPreacher({name}:{name: string }) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('preacher')
    .insert({name: name})
    .select()
    .single()

  if(error) {
    throw error
  }
  return true
}



// Función para crear un nuevo preacher
export async function createPreacher(preacher: Omit<Preacher, 'id' | 'created_at'>): Promise<Preacher> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('preacher')
    .insert([preacher])
    .select()
    .single();
  
  if (error) {
    throw error;
  }
  
  return {
    ...data,
    created_at: new Date(data.created_at)
  };
}

export async function getPreachersRoles() {
  const supabase = await createClient()

  const { data, error } = await supabase
  .from("preacher_role")
  .select()
  if (error) {
    throw error
  }
  return data as PreacherRole[]
}

// Función para actualizar un preacher
export async function updatePreacher(id: number, updates: Partial<Omit<Preacher, 'id' | 'created_at'>>): Promise<Preacher> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('preacher')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
  
  if (error) {
    throw error;
  }
  
  return {
    ...data,
    created_at: new Date(data.created_at)
  };
}

// Función para eliminar un preacher
export async function deletePreacher(id: number): Promise<void> {
  const supabase = await createClient();
  const { error } = await supabase
    .from('preacher')
    .delete()
    .eq('id', id);
  
  if (error) {
    throw error;
  }
}