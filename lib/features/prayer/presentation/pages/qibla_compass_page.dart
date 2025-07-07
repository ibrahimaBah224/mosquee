import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage>
    with TickerProviderStateMixin {
  bool _hasPermission = false;
  bool _isLoading = true;
  String _errorMessage = '';
  Position? _currentPosition;
  double _qiblaAngle = 0.0;
  double _deviceHeading = 0.0;
  bool _orientationSupported = false;
  StreamSubscription? _orientationSubscription;

  late AnimationController _compassAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // Coordonnées de La Mecque (Kaaba)
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _compassAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _requestPermissions();
  }

  @override
  void dispose() {
    _compassAnimationController.dispose();
    _pulseAnimationController.dispose();
    _orientationSubscription?.cancel();
    super.dispose();
  }

  void _startOrientationListener() {
    // Sur mobile, on peut utiliser sensors_plus pour l'orientation
    // Sur web, on utilise les contrôles manuels
    if (!kIsWeb) {
      // TODO: Implémenter sensors_plus pour Android/iOS si nécessaire
      debugPrint('Capteurs natifs disponibles sur mobile');
    } else {
      debugPrint('Mode web - utilisation des contrôles manuels');
    }
  }

  void _setupOrientationListener() {
    // Version simplifiée sans APIs web
    debugPrint('Configuration orientation simplifiée');
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Vérifier les permissions de localisation
      final locationPermission = await Geolocator.checkPermission();

      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
            _errorMessage =
                'Permission de localisation requise pour calculer la direction de La Mecque';
          });
          return;
        }
      }

      // Vérifier si la localisation est activée
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _errorMessage =
              'Veuillez activer les services de localisation dans les paramètres';
        });
        return;
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Calculer la direction vers La Mecque
      final qiblaAngle = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _hasPermission = true;
        _isLoading = false;
        _currentPosition = position;
        _qiblaAngle = qiblaAngle;
      });

      // Démarrer l'écoute de l'orientation sur web
      _startOrientationListener();
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _errorMessage =
            'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  double _calculateQiblaDirection(double userLat, double userLng) {
    // Convertir en radians
    final lat1 = userLat * (math.pi / 180);
    final lng1 = userLng * (math.pi / 180);
    final lat2 = meccaLatitude * (math.pi / 180);
    final lng2 = meccaLongitude * (math.pi / 180);

    // Calcul de l'azimut (direction) vers La Mecque
    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final azimuth = math.atan2(y, x);

    // Convertir en degrés et normaliser (0-360)
    double bearing = azimuth * (180 / math.pi);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _calculateDistance(double userLat, double userLng) {
    return Geolocator.distanceBetween(
            userLat, userLng, meccaLatitude, meccaLongitude) /
        1000; // Convertir en kilomètres
  }

  // Calculer l'angle relatif entre la direction de l'appareil et la Qibla
  double get _relativeQiblaAngle {
    double relative = _qiblaAngle - _deviceHeading;
    // Normaliser l'angle entre -180 et 180
    while (relative > 180) relative -= 360;
    while (relative < -180) relative += 360;
    return relative;
  }

  // Déterminer si l'utilisateur fait face à La Mecque
  bool get _isFacingQibla {
    return _relativeQiblaAngle.abs() < 15; // Tolérance de ±15°
  }

  // Ajuster manuellement la direction (pour le web comme backup)
  void _adjustHeading(double delta) {
    setState(() {
      _deviceHeading = (_deviceHeading + delta) % 360;
      if (_deviceHeading < 0) _deviceHeading += 360;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          kIsWeb ? 'Boussole Qibla (Web Auto)' : 'Boussole Qibla',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _requestPermissions,
            tooltip: 'Actualiser la position',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            SizedBox(height: 20),
            Text(
              'Obtention de votre position...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Initialisation des capteurs d\'orientation...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return _buildErrorWidget();
    }

    return _buildCompass();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70),
                  SizedBox(height: 8),
                  Text(
                    'Pour utiliser la boussole Qibla, nous avons besoin d\'accéder à votre position GPS.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    final distance = _currentPosition != null
        ? _calculateDistance(
            _currentPosition!.latitude, _currentPosition!.longitude)
        : 0.0;

    return Column(
      children: [
        // Indicateur de détection d'orientation
        if (kIsWeb) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _orientationSupported
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _orientationSupported
                    ? Colors.green.withOpacity(0.5)
                    : Colors.orange.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _orientationSupported ? Icons.phone_android : Icons.touch_app,
                  color: _orientationSupported ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _orientationSupported
                      ? 'Détection automatique active - Inclinez votre appareil'
                      : 'Utilisez les boutons ou inclinez votre appareil',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Indicateur de direction et statut
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isFacingQibla
                  ? [
                      Colors.green.withOpacity(0.3),
                      Colors.amber.withOpacity(0.3)
                    ]
                  : [
                      Colors.amber.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2)
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFacingQibla
                  ? Colors.green.withOpacity(0.5)
                  : Colors.amber.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFacingQibla ? Icons.check_circle : Icons.explore,
                    color: _isFacingQibla ? Colors.green : Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isFacingQibla
                        ? 'Vous faites face à La Mecque!'
                        : 'Orientez-vous vers La Mecque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isFacingQibla ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoCard(
                    'Qibla',
                    '${_qiblaAngle.toStringAsFixed(1)}°',
                    Icons.explore,
                    Colors.amber,
                  ),
                  _buildInfoCard(
                    'Votre direction',
                    '${_deviceHeading.toStringAsFixed(1)}°',
                    Icons.navigation,
                    Colors.blue,
                  ),
                  _buildInfoCard(
                    'Distance',
                    '${distance.toStringAsFixed(0)} km',
                    Icons.straighten,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Boussole principale
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercles de fond
                ...List.generate(3, (index) {
                  return Container(
                    width: 280 - (index * 40),
                    height: 280 - (index * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1 - (index * 0.02)),
                        width: 1,
                      ),
                    ),
                  );
                }),

                // Boussole rotative (suit la direction de l'appareil)
                Transform.rotate(
                  angle: -_deviceHeading * (math.pi / 180),
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1E3A8A).withOpacity(0.8),
                          const Color(0xFF0D1B2A),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Points cardinaux
                        ..._buildCardinalPoints(),
                      ],
                    ),
                  ),
                ),

                // Indicateur Qibla fixe (toujours vers La Mecque)
                Transform.rotate(
                  angle: (_qiblaAngle - _deviceHeading) * (math.pi / 180),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isFacingQibla
                            ? _pulseAnimation.value * 1.2
                            : _pulseAnimation.value,
                        child: Container(
                          width: 8,
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 100),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: _isFacingQibla
                                  ? [Colors.green, Colors.lightGreen]
                                  : [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (_isFacingQibla
                                        ? Colors.green
                                        : Colors.amber)
                                    .withOpacity(0.8),
                                blurRadius: _isFacingQibla ? 12 : 8,
                                spreadRadius: _isFacingQibla ? 4 : 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Centre de la boussole avec icône Kaaba
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isFacingQibla ? Colors.green : Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: (_isFacingQibla ? Colors.green : Colors.amber)
                            .withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contrôles manuels (comme backup)
        if (kIsWeb && !_orientationSupported) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Contrôles Manuels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _adjustHeading(-45),
                      icon: const Icon(Icons.rotate_left, size: 20),
                      label: const Text('Gauche'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _deviceHeading = 0),
                      icon: const Icon(Icons.gps_fixed, size: 20),
                      label: const Text('Nord'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _adjustHeading(45),
                      icon: const Icon(Icons.rotate_right, size: 20),
                      label: const Text('Droite'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Informations en bas
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? _isFacingQibla
                        ? 'Parfait! La flèche verte indique que vous êtes orienté vers La Mecque.'
                        : _orientationSupported
                            ? 'Inclinez votre appareil ou tournez-vous physiquement vers La Mecque.'
                            : 'Utilisez les boutons ou tournez-vous physiquement vers La Mecque.'
                    : _isFacingQibla
                        ? 'Parfait! Vous êtes orienté vers La Mecque.'
                        : 'Tournez-vous lentement vers La Mecque.',
                style: TextStyle(
                  color: _isFacingQibla ? Colors.lightGreen : Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCardinalPoints() {
    final points = ['N', 'E', 'S', 'W'];

    return points.map((point) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Center(
          child: Text(
            point,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }
}
