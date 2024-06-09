import 'package:dart_openai/dart_openai.dart';
import 'env/env.dart';

class OpenAIService {
  Future<String> createModel(String sendMessage) async {
    OpenAI.apiKey = Env.apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "넌 지금 선생님이야 내가 준 텍스트를 설명해야하고 내가 물어보는 질문에 답을 해줘",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          sendMessage,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
    await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: requestMessages,
      maxTokens: 1000,
    );

    String message =
    chatCompletion.choices.first.message.content![0].text.toString();
    return message;
  }
}
