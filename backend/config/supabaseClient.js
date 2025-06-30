import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL // supabase URL
const supabaseKey = process.env.SUPABASE_API_ANON //supabase Anon Key
const supabase = createClient(supabaseUrl, supabaseKey)

export default supabase