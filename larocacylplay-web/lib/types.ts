// export interface Preacher {
//   id: number;
//   name: string;
//   preacher_role?: {
//     id: number;
//     name: string;
//   };
//   thumb_id?: string;
// }

import { UUID } from "crypto"

// export interface Series {
//   id: number;
//   created_at: Date;
//   name: string;
//   description?: string;
//   thumb_id?: string;
//   preaches?: Preach[];
// }

// export interface Event {
//   id: number;
//   created_at: Date;
//   name: string;
//   description?: string;
//   started_at: Date;
//   ended_at: Date;
//   thumb_id?: string;
//   preaches?: Preach[];
// }

// export interface Preach {
//   id: number;
//   created_at: Date;
//   title: string;
//   description?: string;
//   preacher_id?: Preacher;
//   date: Date;
//   video: string;
//   serie_id: Series;
//   thumb_id?: string;
//   congress_id?: Event;
// }
export type Preacher = {
  id: string
  name: string
  preacher_role_id: {
    id: number,
    name: string
  }
  thumb_id?: string
}
export type PreachCollection = {
  id: number
  title: string
  description?: string
  thumb_id?: string
  isPublic: boolean
  collection_type_id: {
    id: number,
    name: string
  }
  created_at: Date
  updated_at: Date
  ended_at: Date
}

export type Preach = {
  id: number
  title: string
  description?: string
  date: Date
  video_url: string
  thumb_id?: string
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

export type PreacherRole = {
  id: string
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