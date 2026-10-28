enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final String message;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isGenerating;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.isGenerating = false,
    this.isError = false,
  });

  ChatMessage.user({
    required this.id,
    required this.message,
    DateTime? timestamp,
  })  : sender = MessageSender.user,
        timestamp = timestamp ?? DateTime.now(),
        isGenerating = false,
        isError = false;

  ChatMessage.ai({
    required this.id,
    required this.message,
    DateTime? timestamp,
    this.isGenerating = false,
    this.isError = false,
  })  : sender = MessageSender.ai,
        timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == MessageSender.user;

  ChatMessage copyWith({
    String? id,
    String? message,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isGenerating,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isGenerating: isGenerating ?? this.isGenerating,
      isError: isError ?? this.isError,
    );
  }
}
