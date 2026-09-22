import 'dart:convert';

import 'package:http/http.dart' as http;

/// What a barcode lookup found, if anything — just enough to prefill a new
/// item's name and cover photo.
class BarcodeLookupResult {
  final String? name;
  final String? imageUrl;
  const BarcodeLookupResult({this.name, this.imageUrl});

  bool get isEmpty => name == null && imageUrl == null;
}

/// Looks up a scanned barcode against public, keyless product databases —
/// Open Library for ISBNs (books/comics), UPCitemdb's trial endpoint
/// otherwise (general retail goods). Coverage for niche collectibles
/// (indie figurines, etc.) is inherently patchy; a miss just means the user
/// fills the form in by hand, same as before this feature existed.
Future<BarcodeLookupResult?> lookupBarcode(String code) async {
  if (_looksLikeIsbn(code)) {
    final result = await _lookupOpenLibrary(code);
    if (result != null && !result.isEmpty) return result;
  }
  return _lookupUpcItemDb(code);
}

bool _looksLikeIsbn(String code) =>
    code.length == 13 && (code.startsWith('978') || code.startsWith('979'));

Future<BarcodeLookupResult?> _lookupOpenLibrary(String isbn) async {
  try {
    final uri = Uri.parse(
      'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final entry = body['ISBN:$isbn'] as Map<String, dynamic>?;
    if (entry == null) return null;
    final cover = entry['cover'] as Map<String, dynamic>?;
    return BarcodeLookupResult(
      name: entry['title'] as String?,
      imageUrl: (cover?['large'] ?? cover?['medium']) as String?,
    );
  } catch (_) {
    return null;
  }
}

Future<BarcodeLookupResult?> _lookupUpcItemDb(String code) async {
  try {
    final uri = Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$code');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List?;
    if (items == null || items.isEmpty) return null;
    final item = items.first as Map<String, dynamic>;
    final images = item['images'] as List?;
    return BarcodeLookupResult(
      name: item['title'] as String?,
      imageUrl: images != null && images.isNotEmpty ? images.first as String? : null,
    );
  } catch (_) {
    return null;
  }
}
