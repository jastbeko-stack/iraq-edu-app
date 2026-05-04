/// Static configuration for the project's Supabase backend.
///
/// These values are public-by-design (the URL and the anon/publishable key
/// ship to every browser running the app). The privileged service-role key
/// is NEVER referenced from client code — server-side automation that needs
/// it goes through Cloud Functions / a separate backend.
abstract final class SupabaseConfig {
  static const String url = 'https://deyfxhodayxvzjuxadrn.supabase.co';

  /// Publishable key (`sb_publishable_...`) — the public client-side key.
  /// Storage / Postgres access is gated by RLS policies, not this key.
  static const String anonKey =
      'sb_publishable_2hdC01k-3ozs_u-Ooc6grA_7mhbNJZn';

  /// Storage bucket holding bundled and admin-uploaded study-guide PDFs.
  /// Must be created as **Public** in the Supabase dashboard so download
  /// URLs work without a signed-URL flow.
  static const String pdfBucket = 'pdfs';

  /// Postgres table backing the study-guide catalog.
  static const String guidesTable = 'guides';

  /// Realtime channel used to invalidate the local cache when other clients
  /// mutate the guides table.
  static const String guidesChannel = 'public:guides';
}
