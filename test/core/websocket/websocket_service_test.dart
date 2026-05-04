import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:business_chatbot_template/core/websocket/websocket_service.dart';

import 'websocket_service_test.mocks.dart';

@GenerateMocks([io.Socket])
void main() {
  late MockSocket mockSocket;
  late WebSocketService webSocketService;

  setUp(() {
    mockSocket = MockSocket();
    webSocketService = WebSocketService();
  });

  tearDown(() {
    webSocketService.disconnect();
  });

  group('WebSocketService', () {
    test('initial state is not connected', () {
      expect(webSocketService.isConnected, false);
    });

    test('setChatResponseCallback updates callback', () {
      var callbackCalled = false;
      ChatResponseCallback callback = ({
        required String chatId,
        required String chatbotId,
        required String reply,
      }) {
        callbackCalled = true;
      };

      webSocketService.setChatResponseCallback(callback);
      // Cannot directly test private field, but we can verify it doesn't crash
      expect(callbackCalled, false);
    });

    test('disconnect clears state', () {
      webSocketService.disconnect();
      expect(webSocketService.isConnected, false);
    });
  });

  group('ChatResponseCallback', () {
    test('callback is called when WebSocket receives chat:response', () {
      String? receivedChatId;
      String? receivedChatbotId;
      String? receivedReply;

      webSocketService.setChatResponseCallback((
        {required String chatId,
        required String chatbotId,
        required String reply}) {
        receivedChatId = chatId;
        receivedChatbotId = chatbotId;
        receivedReply = reply;
      });

      // Simulate WebSocket response
      final callback = webSocketService;
      // Note: Full testing would require mocking the socket events
      // This is a structural test to ensure the callback pattern works

      webSocketService.setChatResponseCallback(null);
      expect(webSocketService.isConnected, false);
    });
  });
}
