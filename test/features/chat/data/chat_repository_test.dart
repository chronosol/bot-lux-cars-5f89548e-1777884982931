import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_chatbot_template/features/chat/data/chat_repository.dart';
import 'package:business_chatbot_template/features/chat/domain/message.dart';

import 'chat_repository_test.mocks.dart';

@GenerateMocks([Dio, SharedPreferences])
void main() {
  late MockDio mockDio;
  late MockSharedPreferences mockPrefs;
  late ChatRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockPrefs = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({});
    repository = ChatRepository();
  });

  tearDown(() {
    // Clean up if needed
  });

  group('ChatRepository', () {
    test('initial state has no chatId', () async {
      expect(repository.isChatInitialized, false);
    });

    test('getChatId returns existing chatId from storage', () async {
      SharedPreferences.setMockInitialValues({
        'chat_id': 'existing_chat_123',
      });

      final chatId = await repository.getChatId();
      expect(chatId, 'existing_chat_123');
    });

    test('sendMessage is fire-and-forget (returns void)', () async {
      // This test verifies the method signature returns Future<void>
      // Actual HTTP call would be mocked in integration tests

      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'chatId': 'new_chat_456'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/chatbots/mobile'),
        ),
      );

      // Verify the method exists and returns void
      expect(
        repository.sendMessage(
          sessionId: 'session_123',
          userMessage: 'Hello',
          history: [],
          chatbotId: 'bot_123',
        ),
        isA<Future<void>>(),
      );
    });

    test('initializeChat generates new chatId if none exists', () async {
      SharedPreferences.setMockInitialValues({});

      final chatId = await repository.initializeChat();
      expect(chatId, isNotNull);
      expect(chatId, startsWith('chat_'));
    });
  });

  group('ChatException', () {
    test('toString returns message', () {
      const exception = ChatException('Test error');
      expect(exception.toString(), 'Test error');
    });
  });
}
