import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/business_profile_screen.dart';
import '../../features/chat/presentation/screens/chat_history_screen.dart';
import '../../features/chat/presentation/screens/rate_assistant_screen.dart';
import '../../features/chat/presentation/screens/contact_support_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/chat/:chatbotId',
      builder: (context, state) {
        final chatbotId = state.pathParameters['chatbotId']!;
        final name = state.uri.queryParameters['name'];
        final business = state.uri.queryParameters['business'];
        return ChatScreen(
          chatbotId: chatbotId,
          chatbotName: name?.isNotEmpty == true ? Uri.decodeComponent(name!) : null,
          businessName: business?.isNotEmpty == true ? Uri.decodeComponent(business!) : null,
        );
      },
    ),
    GoRoute(
      path: '/chat/profile',
      builder: (_, __) => const BusinessProfileScreen(),
    ),
    GoRoute(
      path: '/chat/history',
      builder: (_, __) => const ChatHistoryScreen(),
    ),
    GoRoute(
      path: '/chat/rate',
      builder: (_, __) => const RateAssistantScreen(),
    ),
    GoRoute(
      path: '/chat/support',
      builder: (_, __) => const ContactSupportScreen(),
    ),
  ],
);
