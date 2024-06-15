import 'package:dart_openai/dart_openai.dart';
import 'env/env.dart';

class OpenAIService {
  Future<String> createModel(String sendMessage) async {
    OpenAI.apiKey = Env.apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "입력되는 텍스트의 언어에 맞춰서 해당 언어로 요약해줘. 만약에 대화가 질문 형식으로 들어오면 질문에도 답을 해줘!",
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
