import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/**
 * Gets the path of the home directory.
 */
String getHomeDirectoryPath() {
  String path = "";
  if (Platform.isMacOS || Platform.isLinux) {
    path = '${Platform.environment['HOME']}';
  } else if (Platform.isWindows) {
    path = '${Platform.environment['USERPROFILE']}';
  }
  return path;
}

/**
 * Initializes the folder if it doesn't exist.
 */
Future<void> initFolder() async {
  final homePath = getHomeDirectoryPath();
  String modulesFolder = '$homePath/Serve/modules';
  final directory = Directory(modulesFolder);
  bool exists = await directory.exists();

  if (!exists) {
    final newDir = Directory(modulesFolder);
    newDir.create(recursive: true);
  }

  downloadJsonFiles(modulesFolder);
}

/**
 * Downloads the latest json files from the github repo to the path given.
 */
void downloadJsonFiles(path) async {
  final client = http.Client();
  final repoResponse = await client.get(Uri.parse(
      'https://raw.githubusercontent.com/UuBroot/Serve-Modules/main/repo.json'));
  List<dynamic> repoData = jsonDecode(repoResponse.body);

  if (repoResponse.statusCode == 200) {
    for (int i = 0; i < repoData.length; i++) {
      final response = await client.get(Uri.parse(
          'https://raw.githubusercontent.com/UuBroot/Serve-Modules/main/modules/${repoData[i]}.json'));
      final data = jsonDecode(response.body);

      print(data);
      final String filepath = path + "/" + repoData[i] + ".json";
      print(filepath);
      final File file = File(filepath);
      final String jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    }
  } else {
    print('Failed to fetch repository content');
  }

  client.close();
}

/**
 * Reads the json files from the modules folder.
 */

Future<List<Map<String, dynamic>>> readJsonFile() async {
  final folder = Directory('${getHomeDirectoryPath()}/Serve/modules');
  final List<Map<String, dynamic>> jsonList = [];

  if (await folder.exists()) {
    final files = folder.listSync();

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final String data = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(data);
        jsonList.add(jsonData);
      }
    }
  } else {
    print('Folder does not exist');
  }
  print(jsonList);
  return jsonList;
}
