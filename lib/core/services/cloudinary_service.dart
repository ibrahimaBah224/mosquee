import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static CloudinaryService? _instance;
  static CloudinaryService get instance => _instance ??= CloudinaryService._();

  CloudinaryService._();

  late String _cloudName;
  late String _apiKey;
  late String _apiSecret;
  bool _initialized = false;

  // Configuration par défaut
  static const String _defaultCloudName = 'ddbhp3vpj';
  static const String _defaultApiKey = '947988289152758';
  static const String _defaultApiSecret = 'YpMAH-NKCXIbLqTEh3qztA4s5JU';

  // Dossiers pour organiser les fichiers
  static const String _newsFolder = 'momed/news';
  static const String _eventsFolder = 'momed/events';
  static const String _booksFolder = 'momed/books';
  static const String _profilesFolder = 'momed/profiles';
  static const String _mosqueeFolder = 'momed/mosquee';
  static const String _donationsFolder = 'momed/donations';

  /// Initialise Cloudinary avec les clés d'API
  Future<void> initialize({
    required String cloudName,
    required String apiKey,
    required String apiSecret,
  }) async {
    try {
      _cloudName = cloudName;
      _apiKey = apiKey;
      _apiSecret = apiSecret;
      _initialized = true;

      debugPrint('Cloudinary initialized successfully with cloud: $cloudName');
    } catch (e) {
      debugPrint('Failed to initialize Cloudinary: $e');
      rethrow;
    }
  }

  /// Vérifie si Cloudinary est initialisé
  bool get isInitialized => _initialized;

  /// Upload un fichier vers Cloudinary
  Future<CloudinaryUploadResponse?> uploadFile({
    required dynamic file, // File ou Uint8List
    required String fileName,
    required CloudinaryFolder folder,
    Map<String, String>? tags,
    String? publicId,
  }) async {
    if (!_initialized) {
      throw Exception('Cloudinary not initialized. Call initialize() first.');
    }

    try {
      // Génère un ID unique si pas fourni
      publicId ??= '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';

      // Détermine le dossier
      String folderPath = _getFolderPath(folder);
      String fullPublicId = '$folderPath/$publicId';

      // Tags par défaut
      List<String> uploadTags = [
        'momed',
        folder.name,
        ...?tags?.values,
      ];

      // Préparer les données pour l'upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
      );

      // Signature pour sécuriser l'upload
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateSignature(fullPublicId, timestamp, uploadTags);

      // Ajouter les champs requis
      request.fields['public_id'] = fullPublicId;
      request.fields['timestamp'] = timestamp;
      request.fields['api_key'] = _apiKey;
      request.fields['signature'] = signature;
      request.fields['tags'] = uploadTags.join(',');

      // Ajouter le fichier
      if (file is File) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      } else if (file is Uint8List) {
        request.files.add(
            http.MultipartFile.fromBytes('file', file, filename: fileName));
      } else {
        throw ArgumentError('File must be File or Uint8List');
      }

      // Envoyer la requête
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        debugPrint('File uploaded successfully: ${jsonResponse['public_id']}');

        return CloudinaryUploadResponse(
          publicId: jsonResponse['public_id'],
          url: jsonResponse['secure_url'],
          width: jsonResponse['width'],
          height: jsonResponse['height'],
        );
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      debugPrint('Failed to upload file: $e');
      rethrow;
    }
  }

  /// Génère une URL optimisée pour une image
  String getOptimizedImageUrl({
    required String publicId,
    int? width,
    int? height,
    CloudinaryImageQuality quality = CloudinaryImageQuality.auto,
    CloudinaryImageFormat format = CloudinaryImageFormat.auto,
    bool progressive = true,
  }) {
    if (!_initialized) return '';

    try {
      List<String> transformations = [];

      // Redimensionnement si spécifié
      if (width != null || height != null) {
        String resize = 'c_fill';
        if (width != null) resize += ',w_$width';
        if (height != null) resize += ',h_$height';
        transformations.add(resize);
      }

      // Qualité
      String qualityStr = _mapQuality(quality);
      if (qualityStr.isNotEmpty) {
        transformations.add('q_$qualityStr');
      }

      // Format
      String formatStr = _mapFormat(format);
      if (formatStr.isNotEmpty && formatStr != 'auto') {
        transformations.add('f_$formatStr');
      }

      // Construction de l'URL
      String baseUrl = 'https://res.cloudinary.com/$_cloudName/image/upload';
      String transformation =
          transformations.isNotEmpty ? '/${transformations.join(',')}' : '';

      return '$baseUrl$transformation/$publicId';
    } catch (e) {
      debugPrint('Failed to generate image URL: $e');
      return '';
    }
  }

  /// Génère une URL pour une image thumbnail
  String getThumbnailUrl({
    required String publicId,
    int size = 150,
    CloudinaryImageQuality quality = CloudinaryImageQuality.auto,
  }) {
    return getOptimizedImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      quality: quality,
    );
  }

  /// Supprime un fichier de Cloudinary
  Future<bool> deleteFile(String publicId) async {
    if (!_initialized) return false;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateDeleteSignature(publicId, timestamp);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint('File deleted successfully: $publicId');
        return jsonResponse['result'] == 'ok';
      }
      return false;
    } catch (e) {
      debugPrint('Failed to delete file: $e');
      return false;
    }
  }

  /// Upload d'image spécifique pour les actualités
  Future<CloudinaryUploadResponse?> uploadNewsImage({
    required dynamic file,
    required String fileName,
    String? customId,
  }) async {
    return uploadFile(
      file: file,
      fileName: fileName,
      folder: CloudinaryFolder.news,
      publicId: customId,
      tags: {'content_type': 'news'},
    );
  }

  /// Upload d'image spécifique pour les événements
  Future<CloudinaryUploadResponse?> uploadEventImage({
    required dynamic file,
    required String fileName,
    String? customId,
  }) async {
    return uploadFile(
      file: file,
      fileName: fileName,
      folder: CloudinaryFolder.events,
      publicId: customId,
      tags: {'content_type': 'event'},
    );
  }

  /// Upload d'image spécifique pour les livres
  Future<CloudinaryUploadResponse?> uploadBookCover({
    required dynamic file,
    required String fileName,
    String? customId,
  }) async {
    return uploadFile(
      file: file,
      fileName: fileName,
      folder: CloudinaryFolder.books,
      publicId: customId,
      tags: {'content_type': 'book'},
    );
  }

  /// Upload d'image spécifique pour les profils
  Future<CloudinaryUploadResponse?> uploadProfileImage({
    required dynamic file,
    required String fileName,
    String? customId,
  }) async {
    return uploadFile(
      file: file,
      fileName: fileName,
      folder: CloudinaryFolder.profiles,
      publicId: customId,
      tags: {'content_type': 'profile'},
    );
  }

  // Méthodes utilitaires privées
  String _getFolderPath(CloudinaryFolder folder) {
    switch (folder) {
      case CloudinaryFolder.news:
        return _newsFolder;
      case CloudinaryFolder.events:
        return _eventsFolder;
      case CloudinaryFolder.books:
        return _booksFolder;
      case CloudinaryFolder.profiles:
        return _profilesFolder;
      case CloudinaryFolder.mosquee:
        return _mosqueeFolder;
      case CloudinaryFolder.donations:
        return _donationsFolder;
    }
  }

  String _mapQuality(CloudinaryImageQuality quality) {
    switch (quality) {
      case CloudinaryImageQuality.auto:
        return 'auto';
      case CloudinaryImageQuality.low:
        return '60';
      case CloudinaryImageQuality.medium:
        return '80';
      case CloudinaryImageQuality.high:
        return '90';
    }
  }

  String _mapFormat(CloudinaryImageFormat format) {
    switch (format) {
      case CloudinaryImageFormat.auto:
        return 'auto';
      case CloudinaryImageFormat.webp:
        return 'webp';
      case CloudinaryImageFormat.jpg:
        return 'jpg';
      case CloudinaryImageFormat.png:
        return 'png';
    }
  }

  String _generateSignature(
      String publicId, String timestamp, List<String> tags) {
    final params =
        'public_id=$publicId&tags=${tags.join(',')}&timestamp=$timestamp$_apiSecret';
    var bytes = utf8.encode(params);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  String _generateDeleteSignature(String publicId, String timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    var bytes = utf8.encode(params);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  static const Uuid _uuid = Uuid();
}

/// Réponse d'upload Cloudinary
class CloudinaryUploadResponse {
  final String publicId;
  final String url;
  final int? width;
  final int? height;

  CloudinaryUploadResponse({
    required this.publicId,
    required this.url,
    this.width,
    this.height,
  });
}

/// Énumération des dossiers Cloudinary
enum CloudinaryFolder {
  news,
  events,
  books,
  profiles,
  mosquee,
  donations,
}

/// Énumération des qualités d'image
enum CloudinaryImageQuality {
  auto,
  low,
  medium,
  high,
}

/// Énumération des formats d'image
enum CloudinaryImageFormat {
  auto,
  webp,
  jpg,
  png,
}
