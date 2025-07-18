import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Topics pour les notifications en diffusion
  static const String TOPIC_ALL_USERS = 'all_users';
  static const String TOPIC_PRAYER_TIMES = 'prayer_times';
  static const String TOPIC_EVENTS = 'events';
  static const String TOPIC_DONATIONS = 'donations';
  static const String TOPIC_STAFF = 'staff';
  static const String TOPIC_ADMIN = 'admin';

  bool _initialized = false;
  late StreamSubscription _liveNotificationSubscription;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Configuration des permissions
      await _requestPermissions();

      // Configuration des notifications locales
      await _initializeLocalNotifications();

      // Configuration des handlers Firebase
      await _setupFirebaseHandlers();

      // S'abonner aux topics par défaut
      await _subscribeToDefaultTopics();

      // 🔥 NOUVEAU : Écouter les notifications live pour tous les appareils
      await _startLiveNotificationListener();

      _initialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Demande les permissions de notifications
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  /// Initialise les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  /// Configure les handlers Firebase
  Future<void> _setupFirebaseHandlers() async {
    // Handler pour les notifications en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler pour les notifications d'arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Handler pour les notifications lorsque l'app est fermée
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationOpen(message);
      }
    });
  }

  /// S'abonne aux topics par défaut
  Future<void> _subscribeToDefaultTopics() async {
    await subscribeToTopic(TOPIC_ALL_USERS);
    debugPrint('✅ Subscribed to default topics');
  }

  /// 🔥 Écoute les notifications live pour diffusion en temps réel
  Future<void> _startLiveNotificationListener() async {
    try {
      debugPrint('🎧 Démarrage du listener de notifications live...');

      _liveNotificationSubscription = _firestore
          .collection('live_notifications')
          .where('timestamp',
              isGreaterThan: DateTime.now().millisecondsSinceEpoch)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) async {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            final data = doc.doc.data() as Map<String, dynamic>;

            // Afficher la notification sur cet appareil
            await _showLocalNotification(
              title: data['title'] ?? 'MOMED',
              body: data['body'] ?? '',
              data: Map<String, dynamic>.from(data['data'] ?? {}),
            );

            debugPrint('📢 Notification broadcast reçue: ${data['title']}');

            // Supprimer la notification après 5 secondes pour éviter l'accumulation
            Future.delayed(const Duration(seconds: 5), () {
              doc.doc.reference.delete().catchError((e) {
                debugPrint('⚠️ Erreur suppression notification: $e');
              });
            });
          }
        }
      });

      debugPrint('✅ Live notification listener démarré');
    } catch (e) {
      debugPrint('❌ Erreur démarrage live listener: $e');
    }
  }

  /// S'abonne à un topic spécifique
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Se désabonne d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Gère les notifications en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
        '📱 Foreground notification received: ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'MOMED',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  /// Gère l'ouverture de notification
  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.notification?.title}');
    // TODO: Navigation vers la page appropriée selon le type
  }

  /// Gère le tap sur notification locale
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('👆 Local notification tapped: ${response.payload}');
    // TODO: Navigation vers la page appropriée
  }

  /// Affiche une notification locale
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      // Sur le web déployé, on utilise le service worker Firebase
      try {
        debugPrint('🌐 Notification web (via service worker): $title');
        debugPrint('💬 Message: $body');

        // Pour le web déployé, simuler une notification locale
        await _simulateWebNotification(title, body);

        debugPrint('✅ Notification web simulée');
      } catch (e) {
        debugPrint('❌ Erreur notification web: $e');
      }
    } else {
      // Utiliser flutter_local_notifications pour mobile
      const androidDetails = AndroidNotificationDetails(
        'momed_notifications',
        'MOMED Notifications',
        channelDescription: 'Notifications importantes de la mosquée',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: data != null ? jsonEncode(data) : null,
      );
    }
  }

  /// Envoie une notification push à un topic (ADMIN ONLY)
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      debugPrint('🔔 Envoi notification broadcast - Plan gratuit Firebase');
      debugPrint('📋 Topic: $topic');
      debugPrint('🏷️ Titre: $title');
      debugPrint('💬 Message: $body');

      // 🔥 NOUVEAU : Écrire dans live_notifications pour broadcast à tous les appareils
      await _sendBroadcastNotification(
        title: title,
        body: body,
        topic: topic,
        data: data,
      );

      // Sauvegarder dans l'historique Firestore
      await _saveNotificationToHistory(
        topic: topic,
        title: title,
        body: body,
        type: type,
        data: data,
      );

      debugPrint(
          '✅ Notification broadcast envoyée à tous les appareils connectés');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi de la notification: $e');
      throw Exception('Erreur lors de l\'envoi de la notification: $e');
    }
  }

  /// Sauvegarde la notification dans l'historique
  Future<void> _saveNotificationToHistory({
    required String topic,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notification_history').add({
        'topic': topic,
        'title': title,
        'body': body,
        'type': type.name,
        'data': data ?? {},
        'sentAt': DateTime.now().toIso8601String(),
        'sentBy': 'admin', // TODO: Récupérer l'utilisateur connecté
      });
    } catch (e) {
      debugPrint('❌ Error saving notification history: $e');
    }
  }

  /// Récupère l'historique des notifications
  Future<List<NotificationHistoryItem>> getNotificationHistory(
      {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection('notification_history')
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return NotificationHistoryItem.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting notification history: $e');
      return [];
    }
  }

  /// Obtient le token FCM de l'appareil
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Notifications spécifiques par type

  /// Notification pour changement d'horaires de prière
  Future<void> notifyPrayerTimesChanged({
    required String mosque,
    required List<String> changedPrayers,
  }) async {
    await sendNotificationToTopic(
      topic: TOPIC_PRAYER_TIMES,
      title: '🕌 Horaires de prière modifiés',
      body:
          'Les horaires de ${changedPrayers.join(", ")} ont été mis à jour à $mosque',
      type: NotificationType.prayerTimes,
      data: {
        'type': 'prayer_times_changed',
        'mosque': mosque,
        'changed_prayers': changedPrayers,
      },
    );
  }

  /// Notification pour nouvel événement
  Future<void> notifyNewEvent({
    required String eventTitle,
    required DateTime eventDate,
    required String eventLocation,
  }) async {
    await sendNotificationToTopic(
      topic: TOPIC_EVENTS,
      title: '📅 Nouvel événement',
      body: '$eventTitle - ${_formatDate(eventDate)} à $eventLocation',
      type: NotificationType.event,
      data: {
        'type': 'new_event',
        'event_title': eventTitle,
        'event_date': eventDate.toIso8601String(),
        'event_location': eventLocation,
      },
    );
  }

  /// Notification pour nouveau don/campagne
  Future<void> notifyNewDonationCampaign({
    required String campaignTitle,
    required double targetAmount,
    required String description,
  }) async {
    await sendNotificationToTopic(
      topic: TOPIC_DONATIONS,
      title: '💰 Nouvelle campagne de don',
      body: '$campaignTitle - Objectif: ${targetAmount.toStringAsFixed(0)} GNF',
      type: NotificationType.donation,
      data: {
        'type': 'new_donation_campaign',
        'campaign_title': campaignTitle,
        'target_amount': targetAmount,
        'description': description,
      },
    );
  }

  /// Notification pour nouveau membre du staff
  Future<void> notifyNewStaffMember({
    required String memberName,
    required String position,
    required StaffType staffType,
  }) async {
    String icon = staffType == StaffType.imam ? '👨‍🏫' : '🎙️';
    String typeText = staffType == StaffType.imam ? 'Imam' : 'Muezzin';

    await sendNotificationToTopic(
      topic: TOPIC_STAFF,
      title: '$icon Nouveau $typeText',
      body: '$memberName rejoint notre équipe en tant que $position',
      type: NotificationType.staff,
      data: {
        'type': 'new_staff_member',
        'member_name': memberName,
        'position': position,
        'staff_type': staffType.name,
      },
    );
  }

  /// Notification générale admin
  Future<void> notifyGeneralAnnouncement({
    required String title,
    required String message,
  }) async {
    await sendNotificationToTopic(
      topic: TOPIC_ALL_USERS,
      title: '📢 $title',
      body: message,
      type: NotificationType.announcement,
      data: {
        'type': 'general_announcement',
        'announcement_title': title,
        'announcement_message': message,
      },
    );
  }

  /// Formate une date pour l'affichage
  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Simule une notification web pour les sites déployés
  Future<void> _simulateWebNotification(String title, String body) async {
    // Pour le web déployé, on log juste les détails
    // Les notifications réelles nécessiteraient un serveur push
    debugPrint('🔔 NOTIFICATION MOMED: $title');
    debugPrint('📝 Message: $body');
    debugPrint('📍 Visible dans l\'historique des notifications admin');
  }

  /// 📡 Envoie une notification broadcast à tous les appareils connectés
  Future<void> _sendBroadcastNotification({
    required String title,
    required String body,
    required String topic,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationData = {
        'title': title,
        'body': body,
        'topic': topic,
        'data': data ?? {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sentBy': 'admin',
      };

      await _firestore.collection('live_notifications').add(notificationData);

      debugPrint('📡 Notification ajoutée à live_notifications pour broadcast');
    } catch (e) {
      debugPrint('❌ Erreur envoi broadcast notification: $e');
      throw e;
    }
  }

  /// Nettoie le listener lors de la fermeture
  void dispose() {
    try {
      _liveNotificationSubscription.cancel();
      debugPrint('🛑 Live notification listener fermé');
    } catch (e) {
      debugPrint('⚠️ Erreur fermeture listener: $e');
    }
  }
}

/// Types de notifications
enum NotificationType {
  general,
  prayerTimes,
  event,
  donation,
  staff,
  announcement,
}

/// Types de staff
enum StaffType {
  imam,
  muezzin,
}

/// Modèle pour l'historique des notifications
class NotificationHistoryItem {
  final String id;
  final String topic;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime sentAt;
  final String sentBy;

  NotificationHistoryItem({
    required this.id,
    required this.topic,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.sentAt,
    required this.sentBy,
  });

  factory NotificationHistoryItem.fromMap(Map<String, dynamic> map, String id) {
    return NotificationHistoryItem(
      id: id,
      topic: map['topic'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      sentAt: DateTime.parse(map['sentAt']),
      sentBy: map['sentBy'] ?? 'unknown',
    );
  }
}
