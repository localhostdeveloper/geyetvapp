import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fetch all categories for the Home Dashboard
 // lib/services/supabase_service.dart

Future<List<Map<String, dynamic>>> getContentByCategory(String categoryId) async {
  print("🛠️ DEBUG: Fetching content for Category ID: $categoryId");
  
  try {
    final response = await _supabase
        .from('content')
        .select()
        .eq('category_id', categoryId);
        
    print("✅ DEBUG: Supabase returned ${response.length} rows");
    
    if (response.isNotEmpty) {
      print("📄 DEBUG: First row data: ${response[0]}");
    }
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("❌ DEBUG: Supabase Error: $e");
    return [];
  }
}
}