import '../models/news.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class NewsRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<String> createNews(News news) async {
    return await _firestoreService.createNews(news);
  }

  Future<void> updateNews(News news) async {
    await _firestoreService.updateNews(news);
  }

  Stream<List<News>> watchPublishedNews() {
    return _firestoreService.watchPublishedNews();
  }

  Future<List<News>> getLatestNews({int limit = 5}) async {
    return await _firestoreService.getLatestNews(limit: limit);
  }

  Future<List<News>> getNewsByCategory(NewsCategory category) async {
    // Cette méthode pourrait être ajoutée au FirestoreService si nécessaire
    final allNews = await getLatestNews(limit: 50);
    return allNews.where((news) => news.category == category).toList();
  }

  Future<void> publishNews(String newsId) async {
    // Logique pour publier une actualité
    // Cette méthode nécessiterait de récupérer l'actualité d'abord
  }

  Future<void> incrementViewCount(String newsId) async {
    await _firestoreService.incrementField('news', newsId, 'viewCount');
  }

  Future<void> pinNews(String newsId) async {
    // Logique pour épingler une actualité
    // Cette méthode nécessiterait de récupérer l'actualité d'abord
  }

  Future<List<News>> getPinnedNews() async {
    // Récupérer les actualités épinglées
    // Cette fonctionnalité nécessiterait une requête avec filtre
    return [];
  }

  Future<List<News>> searchNews(String query) async {
    // Recherche dans les actualités
    // Cette fonctionnalité nécessiterait une configuration de recherche
    return [];
  }
}
