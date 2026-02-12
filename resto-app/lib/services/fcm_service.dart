import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  AuthService? _authService;

  // Canal de notification pour Android
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  Future<void> initialize(AuthService authService) async {
    _authService = authService;

    if (_isInitialized) {
      // Même si déjà initialisé, on met à jour le token si l'utilisateur change
      await _saveTokenToDatabase();
      return;
    }

    // 1. Demander la permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Utilisateur a accepté les notifications');
    } else {
      debugPrint('Utilisateur a refusé ou n\'a pas accepté les notifications');
      return;
    }

    // 2. Configuration pour Android (High Importance Channel)
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'Notifications Importantes', // title
        description: 'Ce canal est utilisé pour les notifications importantes.',
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 3. Gestionnaire de messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Si l'application est au premier plan, on affiche une notification locale
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher', // Assurez-vous d'avoir une icône
              // ou 'launch_background' si vous utilisez l'icône par défaut
            ),
          ),
        );
      }
    });

    // 4. Gestionnaire d'ouverture de notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification ouverte: ${message.data}');
      // TODO: Naviguer vers l'écran approprié en fonction de message.data
      // Par exemple : if (message.data['type'] == 'commande_update') ...
    });

    // 5. Récupérer et envoyer le token
    await _saveTokenToDatabase();

    // 6. Écouter les changements de token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(token: newToken);
    });

    _isInitialized = true;
  }

  Future<void> _saveTokenToDatabase({String? token}) async {
    // Si l'utilisateur n'est pas connecté, on ne fait rien
    if (_authService == null || !_authService!.isAuthenticated) return;

    String? fcmToken = token ?? await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      debugPrint('FCM Token: $fcmToken');
      try {
        await _apiService.post(
          ApiConfig.updateFcmToken,
          data: {'fcm_token': fcmToken},
        );
        debugPrint('Token FCM mis à jour sur le serveur');
      } catch (e) {
        debugPrint('Erreur lors de la mise à jour du token FCM: $e');
      }
    }
  }

  // Appelé manuellement après le login
  Future<void> updateTokenAfterLogin(AuthService authService) async {
    _authService = authService;
    await _saveTokenToDatabase();
  }
}
