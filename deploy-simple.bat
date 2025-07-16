@echo off
echo 🚀 DÉPLOIEMENT MOMED - VERSION GRATUITE FIREBASE
echo =============================================

echo.
echo ℹ️  Déploiement en cours...

REM Déployer seulement Firestore et Hosting (pas de Cloud Functions)
firebase deploy --only firestore:rules,hosting

if %errorlevel% neq 0 (
    echo ❌ Échec du déploiement
    pause
    exit /b 1
)

echo.
echo ✅ 🎉 DÉPLOIEMENT RÉUSSI !
echo.
echo 📋 DÉPLOYÉ :
echo ✅ Règles Firestore
echo ✅ Application Web (Hosting)
echo ✅ Système de notifications locales
echo.
echo 🔗 Votre app est disponible à :
echo https://mosquee-64c87.web.app
echo.
echo 🧪 POUR TESTER :
echo 1. flutter run -d chrome
echo 2. Dashboard Admin → Notifications
echo 3. Testez les boutons rapides
echo.
echo ✅ Système 100%% gratuit, aucun plan payant requis !

pause 