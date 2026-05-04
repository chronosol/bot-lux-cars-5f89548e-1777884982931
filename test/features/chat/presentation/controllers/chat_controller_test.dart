import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:business_chatbot_template/features/chat/presentation/controllers/chat_controller.dart';
import 'package:business_chatbot_template/features/chat/domain/message.dart';

void main() {
  group('ChatControllerParams', () {
    test('creates params with required chatbotId', () {
      const params = ChatControllerParams(chatbotId: 'test_bot_123');
      expect(params.chatbotId, 'test_bot_123');
      expect(params.chatbotName, null);
      expect(params.businessName, null);
    });

    test('creates params with all fields', () {
      const params = ChatControllerParams(
        chatbotId: 'test_bot_123',
        chatbotName: 'Test Bot',
        businessName: 'Test Business',
      );
      expect(params.chatbotId, 'test_bot_123');
      expect(params.chatbotName, 'Test Bot');
      expect(params.businessName, 'Test Business');
    });

    test('equality based on all fields', () {
      const params1 = ChatControllerParams(
        chatbotId: 'bot_123',
        chatbotName: 'Bot',
        businessName: 'Biz',
      );
      const params2 = ChatControllerParams(
        chatbotId: 'bot_123',
        chatbotName: 'Bot',
        businessName: 'Biz',
      );
      const params3 = ChatControllerParams(
        chatbotId: 'bot_456',
        chatbotName: 'Bot',
        businessName: 'Biz',
      );

      expect(params1 == params2, true);
      expect(params1 == params3, false);
    });

    test('hashCode based on all fields', () {
      const params1 = ChatControllerParams(
        chatbotId: 'bot_123',
        chatbotName: 'Bot',
        businessName: 'Biz',
      );
      const params2 = ChatControllerParams(
        chatbotId: 'bot_123',
        chatbotName: 'Bot',
        businessName: 'Biz',
      );

      expect(params1.hashCode, params2.hashCode);
    });
  });

  group('ChatController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('provider is family provider', () {
      const params = ChatControllerParams(chatbotId: 'test_bot');

      expect(
        container.read(chatControllerProvider(params)),
        isA<AsyncValue<ChatSession>>(),
      );
    });

    test('chatResponseCallback updates state with bot reply', () async {
      const params = ChatControllerParams(
        chatbotId: 'test_bot',
        chatbotName: 'Test Bot',
        businessName: 'Test Biz',
      );

      // Wait for initial build
      await container.read(chatControllerProvider(params).future);

      final controller = container.read(chatControllerProvider(params).notifier);

      // Get initial message count
      final initialSession = await container.read(chatControllerProvider(params).future);
      final initialCount = initialSession.messages.length;

      // Simulate WebSocket response callback
      controller.chatResponseCallback(
        chatId: 'chat_123',
        chatbotId: 'test_bot',
        reply: 'Hello! How can I help?',
      );

      // Wait a bit for state to update
      await Future.delayed(Duration(milliseconds: 100));

      final session = container.read(chatControllerProvider(params)).value;
      expect(session, isNotNull);
      expect(session!.messages.length, greaterThan(initialCount));
      expect(
        session.messages.last.isBot,
        true,
      );
    });

    test('welcome message uses chatbotName and businessName', () async {
      const params = ChatControllerParams(
        chatbotId: 'test_bot',
        chatbotName: 'Custom Bot',
        businessName: 'Custom Biz',
      );

      final session = await container.read(chatControllerProvider(params).future);

      expect(
        session.messages.first.content,
        'Hi there! \u{1F44B} I\'m Custom Bot, your personal assistant at Custom Biz. How can I help you today?',
      );
    });
  });

  group('ChatSession', () {
    test('creates session with correct properties', () {
      final session = ChatSession(
        id: 'session_123',
        messages: [ChatMessage.bot('Hello')],
        startedAt: DateTime.now(),
      );

      expect(session.id, 'session_123');
      expect(session.messages.length, 1);
      expect(session.isLoading, false);
      expect(session.errorMessage, null);
    });

    test('copyWith updates properties', () {
      final session = ChatSession(
        id: 'session_123',
        messages: [],
        startedAt: DateTime.now(),
      );

      final updated = session.copyWith(
        isLoading: true,
        errorMessage: 'Test error',
      );

      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'Test error');
      expect(updated.id, session.id); // Unchanged
    });
  });
}
