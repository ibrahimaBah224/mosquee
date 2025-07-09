import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/widgets/cloudinary_image.dart';

class CloudinarySettingsPage extends StatefulWidget {
  const CloudinarySettingsPage({super.key});

  @override
  State<CloudinarySettingsPage> createState() => _CloudinarySettingsPageState();
}

class _CloudinarySettingsPageState extends State<CloudinarySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cloudNameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();

  bool _isLoading = false;
  bool _isTestingConnection = false;
  bool _cloudinaryConfigured = false;
  String? _testImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _cloudNameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Cloudinary'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_cloudinaryConfigured)
            IconButton(
              icon: const Icon(Icons.cloud_done),
              onPressed: null,
              tooltip: 'Cloudinary configuré',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête d'information
              Card(
                color: Colors.purple.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud,
                            color: Colors.purple,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configuration Cloudinary',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Configurez votre compte Cloudinary pour la gestion des images',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 Comment obtenir vos clés Cloudinary :',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('1. Créez un compte sur cloudinary.com'),
                            const Text('2. Allez dans Dashboard > API Keys'),
                            const Text(
                                '3. Copiez Cloud Name, API Key et API Secret'),
                            const Text(
                                '4. Collez-les dans les champs ci-dessous'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Formulaire de configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paramètres de connexion',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cloudNameController,
                        decoration: const InputDecoration(
                          labelText: 'Cloud Name *',
                          hintText: 'ex: mon-cloud-name',
                          prefixIcon: Icon(Icons.cloud_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le Cloud Name est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key *',
                          hintText: 'ex: 123456789012345',
                          prefixIcon: Icon(Icons.key),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'API Key est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apiSecretController,
                        decoration: const InputDecoration(
                          labelText: 'API Secret *',
                          hintText: 'ex: abcdefghijklmnopqrstuvwxyz123456',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'API Secret est obligatoire';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading || _isTestingConnection
                          ? null
                          : _testConnection,
                      icon: _isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check),
                      label: const Text('Tester la connexion'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveSettings,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Sauvegarder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (_testImageUrl != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Test de connexion réussi !',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'Cloudinary est correctement configuré et fonctionnel.'),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Informations sur l'utilisation
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌟 Avantages de Cloudinary',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _buildAdvantageItem(
                          'Optimisation automatique des images'),
                      _buildAdvantageItem('Redimensionnement adaptatif'),
                      _buildAdvantageItem(
                          'CDN mondial pour un chargement rapide'),
                      _buildAdvantageItem(
                          'Formats d\'image modernes (WebP, AVIF)'),
                      _buildAdvantageItem('Compression intelligente'),
                      _buildAdvantageItem('Stockage sécurisé et fiable'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _cloudNameController.text =
          prefs.getString('cloudinary_cloud_name') ?? '';
      _apiKeyController.text = prefs.getString('cloudinary_api_key') ?? '';
      _apiSecretController.text =
          prefs.getString('cloudinary_api_secret') ?? '';

      setState(() {
        _cloudinaryConfigured = CloudinaryService.instance.isInitialized;
      });
    } catch (e) {
      debugPrint('Error loading Cloudinary settings: $e');
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      // Initialiser temporairement Cloudinary pour test
      await CloudinaryService.instance.initialize(
        cloudName: _cloudNameController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        apiSecret: _apiSecretController.text.trim(),
      );

      // Générer une URL de test pour vérifier la configuration
      const testPublicId = 'momed/test/sample_image';
      final testUrl = CloudinaryService.instance.getOptimizedImageUrl(
        publicId: testPublicId,
        width: 100,
        height: 100,
      );

      setState(() {
        _testImageUrl = testUrl;
        _isTestingConnection = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion Cloudinary testée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les paramètres
      await prefs.setString(
          'cloudinary_cloud_name', _cloudNameController.text.trim());
      await prefs.setString(
          'cloudinary_api_key', _apiKeyController.text.trim());
      await prefs.setString(
          'cloudinary_api_secret', _apiSecretController.text.trim());
      await prefs.setBool('cloudinary_configured', true);

      // Initialiser Cloudinary avec les nouveaux paramètres
      await CloudinaryService.instance.initialize(
        cloudName: _cloudNameController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        apiSecret: _apiSecretController.text.trim(),
      );

      setState(() {
        _cloudinaryConfigured = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration Cloudinary sauvegardée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
