import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/book.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _tagsController = TextEditingController();

  BookCategory _selectedCategory = BookCategory.quran;
  BookType _selectedType = BookType.pdf;
  BookLanguage _selectedLanguage = BookLanguage.french;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _pdfUrlController.dispose();
    _audioUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Livre'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: const Icon(Icons.library_books,
                            color: Colors.purple),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enrichir la bibliothèque',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Ajoutez un nouveau livre islamique',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Informations du livre
              _buildSectionCard(
                'Informations du livre',
                [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre *',
                      hintText: 'Ex: Riyadh as-Salihin',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le titre est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Auteur *',
                      hintText: 'Ex: Imam An-Nawawi',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'auteur est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Décrivez le contenu et l\'utilité du livre...',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La description est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _isbnController,
                    decoration: const InputDecoration(
                      labelText: 'ISBN (optionnel)',
                      hintText: '978-XXXXXXXXXX',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Classification
              _buildSectionCard(
                'Classification',
                [
                  DropdownButtonFormField<BookCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: BookCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryName(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<BookType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            prefixIcon: Icon(Icons.file_present),
                          ),
                          items: BookType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getTypeName(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<BookLanguage>(
                          value: _selectedLanguage,
                          decoration: const InputDecoration(
                            labelText: 'Langue',
                            prefixIcon: Icon(Icons.language),
                          ),
                          items: BookLanguage.values.map((language) {
                            return DropdownMenuItem(
                              value: language,
                              child: Text(_getLanguageName(language)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Mots-clés (optionnel)',
                      hintText:
                          'hadith, prière, fiqh (séparés par des virgules)',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Liens et fichiers
              _buildSectionCard(
                'Fichiers et liens',
                [
                  if (_selectedType == BookType.pdf ||
                      _selectedType == BookType.epub) ...[
                    TextFormField(
                      controller: _pdfUrlController,
                      decoration: InputDecoration(
                        labelText:
                            'Lien vers le fichier ${_selectedType.name.toUpperCase()}',
                        hintText:
                            'https://example.com/livre.${_selectedType.name}',
                        prefixIcon: const Icon(Icons.file_download),
                      ),
                      validator: (value) {
                        if ((_selectedType == BookType.pdf ||
                                _selectedType == BookType.epub) &&
                            (value == null || value.isEmpty)) {
                          return 'Le lien vers le fichier est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_selectedType == BookType.audio) ...[
                    TextFormField(
                      controller: _audioUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Lien vers l\'audio',
                        hintText: 'https://example.com/livre-audio.mp3',
                        prefixIcon: Icon(Icons.audiotrack),
                      ),
                      validator: (value) {
                        if (_selectedType == BookType.audio &&
                            (value == null || value.isEmpty)) {
                          return 'Le lien vers l\'audio est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Assurez-vous que les liens sont accessibles publiquement et que vous avez les droits de distribution.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Ajouter le livre'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getCategoryName(BookCategory category) {
    switch (category) {
      case BookCategory.quran:
        return 'Coran et Tafsir';
      case BookCategory.hadith:
        return 'Hadith';
      case BookCategory.fiqh:
        return 'Fiqh (Jurisprudence)';
      case BookCategory.aqidah:
        return 'Aqida (Croyance)';
      case BookCategory.seerah:
        return 'Sira (Biographie du Prophète)';
      case BookCategory.dua:
        return 'Invocations';
      case BookCategory.general:
        return 'Général';
    }
  }

  String _getTypeName(BookType type) {
    switch (type) {
      case BookType.pdf:
        return 'PDF';
      case BookType.epub:
        return 'EPUB';
      case BookType.audio:
        return 'Audio';
    }
  }

  String _getLanguageName(BookLanguage language) {
    switch (language) {
      case BookLanguage.arabic:
        return 'Arabe';
      case BookLanguage.french:
        return 'Français';
      case BookLanguage.english:
        return 'Anglais';
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        language: _selectedLanguage,
        isbn: _isbnController.text.trim().isNotEmpty
            ? _isbnController.text.trim()
            : null,
        pdfUrl: _selectedType == BookType.pdf
            ? _pdfUrlController.text.trim()
            : null,
        audioUrl: _selectedType == BookType.audio
            ? _audioUrlController.text.trim()
            : null,
        coverImageUrl: '', // TODO: Implémenter l'upload d'images
        tags: tags,
        downloadCount: 0,
        rating: 0.0,
        ratingCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.instance.createBook(book);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livre ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/books');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
