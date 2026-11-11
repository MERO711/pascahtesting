import { SUPABASE_ANON_KEY, SUPABASE_URL } from './supabase-config.js';

let clientPromise;

export async function getSupabaseClient() {
  if (!SUPABASE_URL.trim() || !SUPABASE_ANON_KEY.trim()) {
    throw new Error(
      'Supabase is not configured. Add your project URL and publishable/anon key in supabase-config.js.',
    );
  }

  if (!clientPromise) {
    clientPromise = import('https://esm.sh/@supabase/supabase-js@2')
      .then(({ createClient }) => createClient(SUPABASE_URL.trim(), SUPABASE_ANON_KEY.trim()))
      .catch((error) => {
        clientPromise = undefined;
        throw error;
      });
  }

  return clientPromise;
}
