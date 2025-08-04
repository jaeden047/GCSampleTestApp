import { createClient } from '@supabase/supabase-js' 

const supabaseUrl = process.env.SUPABASE_URL // supabase URL
const supabaseKey = process.env.SUPABASE_API_ANON //supabase Anon Key
const supabase = createClient(supabaseUrl, supabaseKey) // Supabase Connection

export default supabase // usable in other .js files, with tag "supabase"
// Connects URL and Key to Supabase Database, for connection and access
// Supabase 'client object' created - that can interface with database. Object labelled 'supabase'