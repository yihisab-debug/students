class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? group;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.group,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    String head(String s) => s.isEmpty ? '' : s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return head(parts[0]) + head(parts[1]);
  }
}

class PendingAccount {
  final String id;
  final String email;
  final String? photoUrl;
  final String? suggestedName;

  const PendingAccount({
    required this.id,
    required this.email,
    this.photoUrl,
    this.suggestedName,
  });
}
