import 'package:http/http.dart' as http;

class EpgService {
  // Replace with your Google Sheets "Publish as CSV" link or hosted file
  final String epgUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRHrJuPypeSixLjosH2bcQCBiRB0zmVJgX2okrQIlmI0DEqzlm3oZtuaVv-0hMpDzrJ8a2haWjJOXLk/pub?output=csv";

 Future<List<Map<String, dynamic>>> fetchRemoteEpg(String channelId) async {
    try {
      final response = await http.get(Uri.parse(epgUrl));
      if (response.statusCode == 200) {
        // FIXED: Parse CSV manually instead of using CsvToListConverter
        List<String> lines = response.body.split('\n');
        List<List<String>> rows = [];
        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          rows.add(line.split(','));
        }
        
        DateTime now = DateTime.now();
        List<Map<String, dynamic>> schedule = [];

        for (var i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.isEmpty) continue;
          
          // Assuming CSV structure: 0: ID, 1: Title, 2: Start, 3: End, 4: Desc
          if (row[0].toString() == channelId) {
            DateTime endTime = DateTime.parse(row[3].toString());
            if (endTime.isAfter(now)) {
              schedule.add({
                'title': row[1].toString(),
                'start': DateTime.parse(row[2].toString()),
                'end': endTime,
                'desc': row[4].toString(),
              });
            }
          }
        }
        return schedule;
      }
    } catch (e) {
      print("EPG Error: $e");
    }
    return [];
  }
}

