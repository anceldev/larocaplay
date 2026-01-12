
import { UUID } from "crypto"

export type Preacher = {
  id: string
  name: string
  preacher_role_id: {
    id: number,
    name: string
  }
  thumb_id?: string
}
export type Collection = {
  id: number
  title: string
  description?: string
  image_id?: string
  is_public: boolean
  collection_type_id: {
    id: number,
    name: string
  }
  created_at: Date
  updated_at: Date
  ended_at: Date
}
export type ShortCollection = {
  id: number
  title: string
  description?: string
}

export type CollectionType = {
  id: number
  name: string
}

export type Preach = {
  id: number
  title: string
  description?: string
  date: Date
  video_id: string
  image_id?: string
  preacher: {
    id: number,
    name: string,
    preacher_role_id: {
      id: number,
      name: string
    }
  }
  created_at: Date
  updated_at: Date
}
export type ShortPreach = {
  id: number,
  title: string,
  description?: string
  date: Date
  preacher: {
    name: string,
    preacher_role_id: {
      name: string
    }
  }
}

export type PreacherRole = {
  id: number
  name: string
}


export interface User {
  id: string;
  created_at: Date;
  updated_at: Date;
  name: string;
  email: string;
  role: UserRole;
}

export interface Profiles {
  user_id: UUID
  display_name?: string
  email: string
  avatar_id?: string
  locale?: string
  profile_role: 'admin' | 'subscriptor' | 'member'
}


export enum UserRole {
  admin,
  pastor,
  supervisor,
  leader,
  member,
}