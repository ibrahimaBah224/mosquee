import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import '../config/app_config.dart';

/// Widget optimisé pour afficher des images Cloudinary
class CloudinaryImage extends StatelessWidget {
  const CloudinaryImage({
    super.key,
    required this.publicId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.quality = CloudinaryImageQuality.auto,
    this.format = CloudinaryImageFormat.auto,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isThumbnail = false,
    this.enableHero = false,
    this.heroTag,
  });

  final String publicId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final CloudinaryImageQuality quality;
  final CloudinaryImageFormat format;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isThumbnail;
  final bool enableHero;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    if (publicId.isEmpty || !CloudinaryService.instance.isInitialized) {
      return _buildFallback();
    }

    final String imageUrl = isThumbnail
        ? CloudinaryService.instance.getThumbnailUrl(
            publicId: publicId,
            size: AppConfig.thumbnailSize,
            quality: quality,
          )
        : CloudinaryService.instance.getOptimizedImageUrl(
            publicId: publicId,
            width: width?.toInt(),
            height: height?.toInt(),
            quality: quality,
            format: format,
          );

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildError(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (enableHero && heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ?? _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        MdiIcons.image,
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.3
            : 48,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Widget avatar optimisé pour les profils
class CloudinaryAvatar extends StatelessWidget {
  const CloudinaryAvatar({
    super.key,
    required this.publicId,
    this.radius = 25,
    this.backgroundColor,
    this.fallbackIcon,
    this.onTap,
  });

  final String publicId;
  final double radius;
  final Color? backgroundColor;
  final IconData? fallbackIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: publicId.isNotEmpty && CloudinaryService.instance.isInitialized
          ? CloudinaryImage(
              publicId: publicId,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              isThumbnail: true,
              borderRadius: BorderRadius.circular(radius),
              errorWidget: _buildFallback(),
            )
          : _buildFallback(),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallback() {
    return Icon(
      fallbackIcon ?? MdiIcons.account,
      size: radius * 0.8,
      color: Colors.grey[600],
    );
  }
}

/// Widget pour afficher des galeries d'images
class CloudinaryImageGallery extends StatelessWidget {
  const CloudinaryImageGallery({
    super.key,
    required this.publicIds,
    this.height = 200,
    this.spacing = 8,
    this.borderRadius,
    this.onImageTap,
  });

  final List<String> publicIds;
  final double height;
  final double spacing;
  final BorderRadius? borderRadius;
  final void Function(String publicId, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (publicIds.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: publicIds.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final publicId = publicIds[index];
          return GestureDetector(
            onTap: () => onImageTap?.call(publicId, index),
            child: CloudinaryImage(
              publicId: publicId,
              height: height,
              width: height * 1.2, // Ratio 4:3
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              enableHero: true,
              heroTag: 'gallery_image_$publicId',
            ),
          );
        },
      ),
    );
  }
}

/// Widget pour uploader des images avec prévisualisation
class CloudinaryImageUploader extends StatefulWidget {
  const CloudinaryImageUploader({
    super.key,
    required this.folder,
    this.onImageUploaded,
    this.maxImages = 1,
    this.aspectRatio = 1.0,
    this.allowMultiple = false,
    this.initialImageUrl,
    this.title = 'Ajouter une photo',
    this.subtitle = 'Tapez pour sélectionner une image',
  });

  final CloudinaryFolder folder;
  final void Function(String? publicId)? onImageUploaded;
  final int maxImages;
  final double aspectRatio;
  final bool allowMultiple;
  final String? initialImageUrl;
  final String title;
  final String subtitle;

  @override
  State<CloudinaryImageUploader> createState() =>
      _CloudinaryImageUploaderState();
}

class _CloudinaryImageUploaderState extends State<CloudinaryImageUploader> {
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Zone d'upload/preview
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _isUploading ? Colors.grey[100] : Colors.grey[50],
            ),
            child: _isUploading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Upload en cours...'),
                      ],
                    ),
                  )
                : _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CloudinaryImage(
                              publicId: _uploadedImageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    color: Colors.white,
                                    onPressed: _pickAndUploadImage,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, size: 16),
                                    color: Colors.white,
                                    onPressed: _removeImage,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.cameraPlus,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Formats acceptés: JPG, PNG, WebP',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Sélectionner une image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Vérifier que Cloudinary est configuré
      if (!CloudinaryService.instance.isInitialized) {
        throw Exception(
            'Cloudinary n\'est pas configuré. Veuillez configurer Cloudinary dans les paramètres.');
      }

      // Upload vers Cloudinary
      CloudinaryUploadResponse? response;

      if (kIsWeb) {
        // Pour le web, utiliser les bytes
        final bytes = await image.readAsBytes();
        response = await CloudinaryService.instance.uploadFile(
          file: bytes,
          fileName: image.name,
          folder: widget.folder,
        );
      } else {
        // Pour mobile, utiliser le File
        final file = File(image.path);
        response = await CloudinaryService.instance.uploadFile(
          file: file,
          fileName: image.name,
          folder: widget.folder,
        );
      }

      if (response != null) {
        setState(() {
          _uploadedImageUrl = response!.publicId;
          _isUploading = false;
        });

        widget.onImageUploaded?.call(response.publicId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Image uploadée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _uploadedImageUrl = null;
    });
    widget.onImageUploaded?.call(null);
  }
}

/// Widget spécialisé pour les photos de profil (avatar circulaire)
class ProfileImageUploader extends StatefulWidget {
  const ProfileImageUploader({
    super.key,
    this.onImageUploaded,
    this.initialImageUrl,
    this.size = 120,
  });

  final void Function(String? publicId)? onImageUploaded;
  final String? initialImageUrl;
  final double size;

  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: Stack(
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  color: Colors.grey[50],
                ),
                child: _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                        ? ClipOval(
                            child: CloudinaryImage(
                              publicId: _uploadedImageUrl!,
                              width: widget.size,
                              height: widget.size,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            MdiIcons.account,
                            size: widget.size * 0.5,
                            color: Colors.grey[400],
                          ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    _uploadedImageUrl != null ? Icons.edit : Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Photo de profil',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (_uploadedImageUrl != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Supprimer'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      if (!CloudinaryService.instance.isInitialized) {
        throw Exception(
            'Cloudinary n\'est pas configuré. Veuillez configurer Cloudinary dans les paramètres.');
      }

      CloudinaryUploadResponse? response;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        response = await CloudinaryService.instance.uploadProfileImage(
          file: bytes,
          fileName: image.name,
        );
      } else {
        final file = File(image.path);
        response = await CloudinaryService.instance.uploadProfileImage(
          file: file,
          fileName: image.name,
        );
      }

      if (response != null) {
        setState(() {
          _uploadedImageUrl = response!.publicId;
          _isUploading = false;
        });

        widget.onImageUploaded?.call(response.publicId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo de profil mise à jour !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _uploadedImageUrl = null;
    });
    widget.onImageUploaded?.call(null);
  }
}
