# Intégration Firebase - Application Mosquée

## Configuration Firebase

L'application Mosquée est maintenant intégrée avec Firebase pour l'authentification, les notifications push et le stockage cloud.

### Configuration du projet

- **Project ID**: `mosquee-64c87`
- **Auth Domain**: `mosquee-64c87.firebaseapp.com`
- **Storage Bucket**: `mosquee-64c87.firebasestorage.app`

### Fonctionnalités Firebase intégrées

#### 1. Authentication
- **Email/Mot de passe** : Connexion et inscription traditionnelles
- **Google Sign-In** : Connexion via compte Google
- **Réinitialisation de mot de passe** : Envoi d'email de réinitialisation
- **Gestion des sessions** : Écoute automatique des changements d'état d'authentification

#### 2. Firebase Messaging (FCM)
- **Notifications push** : Réception de notifications
- **Topics** : Abonnement/désabonnement aux sujets (prières, événements, etc.)
- **Token FCM** : Génération et gestion du token d'appareil

### Architecture de l'authentification

#### Services
- `FirebaseService` : Service singleton pour toutes les interactions Firebase
- Localisation : `lib/core/services/firebase_service.dart`

#### BLoC
- `AuthBloc` : Gestion d'état pour l'authentification
- **Événements** :
  - `AuthCheckRequested` : Vérification de l'état d'authentification
  - `AuthLoginRequested` : Connexion avec email/mot de passe
  - `AuthRegisterRequested` : Inscription avec email/mot de passe
  - `AuthGoogleSignInRequested` : Connexion avec Google
  - `AuthPasswordResetRequested` : Réinitialisation de mot de passe
  - `AuthLogoutRequested` : Déconnexion

- **États** :
  - `AuthInitial` : État initial
  - `AuthLoading` : Chargement en cours
  - `AuthAuthenticated` : Utilisateur authentifié
  - `AuthUnauthenticated` : Utilisateur non authentifié
  - `AuthError` : Erreur d'authentification
  - `AuthPasswordResetSent` : Email de réinitialisation envoyé

#### Pages d'authentification
- `LoginPage` : Page de connexion
- `RegisterPage` : Page d'inscription
- Navigation automatique après authentification

### Configuration des plateformes

#### Web
- Configuration automatique via `DefaultFirebaseOptions.web`
- Fonctionne directement dans le navigateur

#### Android (à configurer)
- Ajouter `google-services.json` dans `android/app/`
- Mettre à jour `android/app/build.gradle`
- Configurer SHA-1 fingerprint dans Firebase Console

#### iOS (à configurer)
- Ajouter `GoogleService-Info.plist` dans `ios/Runner/`
- Mettre à jour `ios/Runner/Info.plist`
- Configurer Bundle ID dans Firebase Console

### Sécurité Firebase

#### Rules Firestore (à configurer)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Authentification requise
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Rules Storage (à configurer)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Fonctionnalités futures

#### Base de données
- **Firestore** : Stockage des données utilisateurs, événements, actualités
- **Collections prévues** :
  - `users` : Profils utilisateurs
  - `events` : Événements de la mosquée
  - `news` : Actualités
  - `prayers` : Historique des prières
  - `donations` : Historique des dons

#### Storage
- **Images** : Upload d'images pour profils, événements
- **Documents** : Stockage de fichiers PDF, audio pour la bibliothèque

#### Analytics
- **Firebase Analytics** : Suivi d'utilisation de l'application
- **Crashlytics** : Reporting automatique des erreurs

### Commandes utiles

#### Installation des dépendances
```bash
flutter pub get
```

#### Lancement de l'application
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

#### Configuration FlutterFire CLI (recommandé)
```bash
# Installation
dart pub global activate flutterfire_cli

# Configuration automatique
flutterfire configure
```

### Dépendances Firebase

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  firebase_messaging: ^15.1.3
  google_sign_in: ^6.2.1
```

### Troubleshooting

#### Erreurs communes

1. **Firebase not initialized**
   - Vérifier l'appel à `Firebase.initializeApp()` dans `main.dart`

2. **Google Sign-In ne fonctionne pas**
   - Vérifier la configuration SHA-1 sur Android
   - Vérifier le Bundle ID sur iOS

3. **Notifications ne fonctionnent pas**
   - Vérifier les permissions de notification
   - Vérifier la configuration FCM

#### Logs Firebase
- Activer les logs détaillés en mode debug
- Surveiller la console Firebase pour les erreurs

### Support

Pour toute question sur l'intégration Firebase, consulter :
- [Documentation Firebase Flutter](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire) 