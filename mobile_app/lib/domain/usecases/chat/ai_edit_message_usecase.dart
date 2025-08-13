import '../../../data/remote/chat_api.dart';
import '../../models/ai_edit_message_result.dart';

class AiEditMessageUseCase {
  final ChatApi _chatApi;

  AiEditMessageUseCase(this._chatApi);

  Future<AiEditMessageResult> execute({
    required String originalMessage,
    required String editPrompt,
    required String receiverId,
  }) {
    return _chatApi.editMessageWithAI(
      originalMessage: originalMessage,
      editPrompt: editPrompt,
      receiverId: receiverId,
    );
  }
}


