import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class EpgService {
  // =========================================================
  // GOOGLE SHEETS CSV LINK
  //
  // HOW TO GET:
  // 1. Create Google Sheet
  // 2. File → Share → Publish to web
  // 3. Select CSV format
  // 4. Paste link below
  //
  // CSV FORMAT:
  //
  // channel_id,title,start,end,description
  // geye_tv,Morning News,2026-05-07 08:00:00,2026-05-07 09:00:00,Daily headlines
  // geye_tv,Movie Time,2026-05-07 09:00:00,2026-05-07 11:00:00,Action movie
  //
  // =========================================================

  final String epgUrl =
      "https://docs.google.com/spreadsheets/d/e/YOUR_ID/pub?output=csv";

  Future<List<Map<String, dynamic>>> fetchRemoteEpg(
    String channelId,
  ) async {
    try {
      final response = await http.get(Uri.parse(epgUrl));

      if (response.statusCode != 200) {
        print("EPG ERROR: Failed to load CSV");
        return [];
      }

      // Clean UTF8 issues
      final csvString = utf8.decode(response.bodyBytes);

      // Parse CSV
      final rows = const CsvToListConverter(
        shouldParseNumbers: false,
      ).convert(csvString);

      if (rows.isEmpty) return [];

      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));

      List<Map<String, dynamic>> schedule = [];

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];

          // SAFETY CHECK
          if (row.length < 5) continue;

          final rowChannelId = row[0].toString().trim();
          final title = row[1].toString().trim();

          final start = DateTime.parse(
            row[2].toString().trim(),
          );

          final end = DateTime.parse(
            row[3].toString().trim(),
          );

          final desc = row[4].toString().trim();

          // =================================================
          // AUTO CLEAN RULES
          // =================================================
          //
          // 1. Only this channel
          // 2. Ignore expired programs
          // 3. Only next 3 days
          //
          // =================================================

          final isCorrectChannel = rowChannelId == channelId;

          final notExpired = end.isAfter(now);

          final within3Days = start.isBefore(threeDaysLater);

          if (isCorrectChannel && notExpired && within3Days) {
            schedule.add({
              'title': title,
              'start': start,
              'end': end,
              'desc': desc,
            });
          }
        } catch (e) {
          print("EPG ROW ERROR: $e");
        }
      }

      // Sort by start time
      schedule.sort(
        (a, b) => a['start'].compareTo(b['start']),
      );

      return schedule;
    } catch (e) {
      print("EPG FETCH ERROR: $e");
      return [];
    }
  }
}