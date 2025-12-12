class Comment {
  final String username;
  final String author;
  final String text;
  final String avatarUrl;
  final String createdAt;

  Comment({
    required this.username,
    required this.author,
    required this.text,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      username: json['username'] ?? '',
      author: json['author'] ?? 'Unknown',
      text: json['text'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}