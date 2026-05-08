import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class EpgService {
  // Replace with your Google Sheets "Publish as CSV" link or hosted file
  final String epgUrl = "https://your-link-here.csv";

  Future<List<Map<String, dynamic>>> fetchRemoteEpg(String channelId) async {
    try {
      final response = await http.get(Uri.parse(epgUrl));
      if (response.statusCode == 200) {
        // FIXED: Removed 'const' because response.body is dynamic
        List<List<dynamic>> rows = CsvToListConverter().convert(response.body);
        
        DateTime now = DateTime.now();
        List<Map<String, dynamic>> schedule = [];

        for (var i = 1; i < rows.length; i++) {
          var row = rows[i];
          // CSV Columns: 0: ID, 1: Title, 2: StartTime, 3: EndTime, 4: Desc
          DateTime startTime = DateTime.parse(row[2].toString());
          DateTime endTime = DateTime.parse(row[3].toString());

          // Only keep data for this channel that hasn't ended yet
          if (row[0].toString() == channelId && endTime.isAfter(now)) {
            schedule.add({
              'title': row[1].toString(),
              'start': startTime,
              'end': endTime,
              'desc': row[4].toString(),
            });
          }
        }
        schedule.sort((a, b) => a['start'].compareTo(b['start']));
        return schedule;
      }
    } catch (e) {
      print("EPG Fetch Error: $e");
    }
    return [];
  }
}