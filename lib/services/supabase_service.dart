import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fetch all categories for the Home Dashboard
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .order('name', ascending: true);
    return response;
  }

  // Fetch content based on category (e.g., all TV channels)
  Future<List<Map<String, dynamic>>> getContentByCategory(String categoryId) async {
    final response = await _supabase
        .from('content')
        .select()
        .eq('category_id', categoryId);
    return response;
  }
}