'use server'
import { createClient } from "./supabase/server"

export const updatePassword = async (projectHmrEvents, formData) => {
  const supabase = await createClient()
  const { data, error } = await supabase.auth.updateUser({
    password: formData.get("password")
  })

  if (error) {
    console.log('error', error)
    return {
      success: '',
      error: error.message
    }
  }
  console.log('Data is', data)
  return {
    success: 'Password updated',
    error: ''
  }
}