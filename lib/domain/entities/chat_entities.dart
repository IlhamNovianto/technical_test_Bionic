enum MessageType { text, image }

enum MessageSender { user, bot }

class ChatEntity {
  final String id;
  final String? text;
  final String? imagePath;
  final MessageType type;
  final MessageSender sender;
  final DateTime createdAt;
  final bool isLoading;

  const ChatEntity({
    required this.id,
    this.text,
    this.imagePath,
    required this.type,
    required this.sender,
    required this.createdAt,
    this.isLoading = false,
  });

  ChatEntity copyWith({
    String? id,
    String? text,
    String? imagePath,
    MessageType? type,
    MessageSender? sender,
    DateTime? createdAt,
    bool? isLoading,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
