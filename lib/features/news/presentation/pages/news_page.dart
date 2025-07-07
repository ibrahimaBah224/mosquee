import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Tout';

  final List<String> categories = [
    'Tout',
    'Événements',
    'Enseignements',
    'Communauté',
    'Ramadan',
    'Hajj',
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Célébration de l\'Aïd al-Fitr 2024',
      'excerpt':
          'Rejoignez-nous pour célébrer la fin du mois béni de Ramadan...',
      'category': 'Événements',
      'date': '15 avril 2024',
      'image': 'assets/images/eid.jpg',
      'author': 'Imam Mohammed',
      'readTime': '3 min',
    },
    {
      'title': 'Les vertus de la prière en congrégation',
      'excerpt':
          'Découvrez l\'importance de prier ensemble et les bénédictions...',
      'category': 'Enseignements',
      'date': '12 avril 2024',
      'image': 'assets/images/prayer.jpg',
      'author': 'Dr. Fatima',
      'readTime': '5 min',
    },
    {
      'title': 'Nouvelle classe de Coran pour enfants',
      'excerpt':
          'Nous sommes heureux d\'annoncer l\'ouverture d\'une nouvelle...',
      'category': 'Communauté',
      'date': '10 avril 2024',
      'image': 'assets/images/kids_quran.jpg',
      'author': 'Ustadh Ahmad',
      'readTime': '2 min',
    },
    {
      'title': 'Préparation spirituelle pour le Ramadan',
      'excerpt': 'Comment se préparer mentalement et spirituellement...',
      'category': 'Ramadan',
      'date': '8 mars 2024',
      'image': 'assets/images/ramadan_prep.jpg',
      'author': 'Imam Mohammed',
      'readTime': '7 min',
    },
    {
      'title': 'Voyage spirituel : Pèlerinage à La Mecque',
      'excerpt': 'Témoignage inspirant d\'un membre de notre communauté...',
      'category': 'Hajj',
      'date': '25 février 2024',
      'image': 'assets/images/hajj.jpg',
      'author': 'Hadji Omar',
      'readTime': '6 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Articles', icon: Icon(Icons.article)),
            Tab(text: 'Vidéos', icon: Icon(Icons.video_library)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildArticlesTab(), _buildVideosTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsletterDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.email, color: Colors.white),
      ),
    );
  }

  Widget _buildArticlesTab() {
    final filteredArticles =
        _selectedCategory == 'Tout'
            ? articles
            : articles
                .where((article) => article['category'] == _selectedCategory)
                .toList();

    return Column(
      children: [
        // Filtres de catégorie
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),

        // Liste des articles
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredArticles.length,
            itemBuilder: (context, index) {
              final article = filteredArticles[index];
              return _buildArticleCard(article);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _openArticle(article),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'article
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article['date'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Titre
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Extrait
                  Text(
                    article['excerpt'],
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Auteur et temps de lecture
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          article['author'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['readTime'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    final videos = [
      {
        'title': 'Khutba du Vendredi : La patience en Islam',
        'duration': '25:30',
        'views': '1,2K vues',
        'date': '12 avril 2024',
      },
      {
        'title': 'Cours : Les piliers de l\'Islam',
        'duration': '45:15',
        'views': '856 vues',
        'date': '10 avril 2024',
      },
      {
        'title': 'Récitation du Coran - Sourate Al-Fatiha',
        'duration': '3:45',
        'views': '2,1K vues',
        'date': '8 avril 2024',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
            title: Text(
              video['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${video['views']} • ${video['date']}'),
                Text(
                  'Durée: ${video['duration']}',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () => _playVideo(video),
          ),
        );
      },
    );
  }

  void _openArticle(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  void _playVideo(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(video['title']!),
            content: const Text('Lecteur vidéo à implémenter'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _showNewsletterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Newsletter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Recevez nos dernières actualités par email'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Votre email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inscription réussie !')),
                  );
                },
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'article
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métadonnées
                  Row(
                    children: [
                      Text(
                        article['category'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Text(
                        article['date'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Text(
                        article['readTime'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Auteur
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          article['author'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Par ${article['author']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contenu
                  Text(
                    article['excerpt'],
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Sauvegarder'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
