import 'package:technical_test/domain/entities/chat_entities.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    super.text,
    super.imagePath,
    required super.type,
    required super.sender,
    required super.createdAt,
    super.isLoading,
  });

  factory ChatModel.fromEntity(ChatEntity entity) => ChatModel(
    id: entity.id,
    text: entity.text,
    imagePath: entity.imagePath,
    type: entity.type,
    sender: entity.sender,
    createdAt: entity.createdAt,
    isLoading: entity.isLoading,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'imagePath': imagePath,
    'type': type.index,
    'sender': sender.index,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
    id: map['id'],
    text: map['text'],
    imagePath: map['imagePath'],
    type: MessageType.values[map['type'] ?? 0],
    sender: MessageSender.values[map['sender'] ?? 0],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
