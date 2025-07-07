import '../models/book.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class BookRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<String> createBook(Book book) async {
    return await _firestoreService.createBook(book);
  }

  Future<void> updateBook(Book book) async {
    await _firestoreService.updateBook(book);
  }

  Stream<List<Book>> watchPublicBooks() {
    return _firestoreService.watchPublicBooks();
  }

  Future<List<Book>> getBooksByCategory(BookCategory category) async {
    return await _firestoreService.getBooksByCategory(category);
  }

  Future<List<Book>> getBooksByType(BookType type) async {
    // Cette méthode pourrait être ajoutée au FirestoreService si nécessaire
    final allBooks = await _firestoreService.watchPublicBooks().first;
    return allBooks.where((book) => book.type == type).toList();
  }

  Future<void> incrementDownloadCount(String bookId) async {
    await _firestoreService.incrementField('books', bookId, 'downloadCount');
  }

  Future<void> rateBook(BookRating rating) async {
    // Logique pour noter un livre
    // Cette méthode nécessiterait une collection dédiée aux évaluations
  }

  Future<List<BookRating>> getBookRatings(String bookId) async {
    // Récupérer les évaluations d'un livre
    return [];
  }

  Future<List<Book>> searchBooks(String query) async {
    // Recherche dans les livres
    // Cette fonctionnalité nécessiterait une configuration de recherche
    return [];
  }

  Future<List<Book>> getPopularBooks({int limit = 10}) async {
    // Récupérer les livres populaires (par nombre de téléchargements)
    final allBooks = await _firestoreService.watchPublicBooks().first;
    allBooks.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return allBooks.take(limit).toList();
  }

  Future<List<Book>> getRecentBooks({int limit = 10}) async {
    // Récupérer les livres récemment ajoutés
    final allBooks = await _firestoreService.watchPublicBooks().first;
    allBooks.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return allBooks.take(limit).toList();
  }

  Future<void> toggleBookVisibility(String bookId) async {
    // Logique pour rendre un livre public/privé
    // Cette méthode nécessiterait de récupérer le livre d'abord
  }
}
