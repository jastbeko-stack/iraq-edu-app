/// A site-wide announcement displayed as a banner on the student home.
///
/// Authored by the admin via the admin portal. Stored in
/// `public.announcements` and streamed to all clients via Supabase
/// Realtime so updates appear instantly.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isActive;
  final DateTime createdAt;

  Announcement copyWith({
    String? title,
    String? body,
    bool? isActive,
  }) =>
      Announcement(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );

  Map<String, dynamic> toRow() => {
        'id': id,
        'title': title,
        'body': body,
        'is_active': isActive,
      };

  static Announcement fromRow(Map<String, dynamic> row) {
    final created = row['created_at'];
    return Announcement(
      id: (row['id'] as String?) ?? '',
      title: (row['title'] as String?) ?? '',
      body: (row['body'] as String?) ?? '',
      isActive: (row['is_active'] as bool?) ?? true,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
