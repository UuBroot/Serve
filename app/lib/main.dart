import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Serve/functions/podman.dart'; //Contains all function related to podman
import 'package:Serve/functions/folderManager.dart'; //Contains all function related to managing the Serve folder
import 'package:Serve/functions/launchUrl.dart';
import 'package:Serve/widgets/moduleWidget.dart';
import 'package:url_launcher/url_launcher.dart';

List modules = []; //The data of the modules
void main() async {
  if (!await isPodmanInstalled()) {
    runApp(const PodmanNotInstalled()); //opens the "podman not found" window
  } else {
    await initFolder(); //Initializes the folder and it's content if it doesn't exist allready.
    await (initNetwork()); //Checks if the podman network exists and created it if it doesn't.

    runApp(App());
  }
}

/// The widget the gets placed in the main scene when no podman is installed.
class PodmanNotInstalled extends StatelessWidget {
  const PodmanNotInstalled({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Center(
              child: Text(
                'Podman is not installed on your system. Please install it to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40),
              ),
            ),
            Center(
              child: InkWell(
                child: Text("https://podman.io/docs/installation"),
                onTap: () => launchURL("https://podman.io/docs/installation"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// The main app widget that contains all the module widgets.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Timer? _timer;
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  @override
  void initState() {
    super.initState();
    // Initialize the stream with an empty list
    _streamController.add([]);

    // Initializes the timer
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (Timer t) {
        _updateStream();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  int halfSecondsTillJsonFileRead = 7;
  List<dynamic> cachedJsonFile = [];
  void _updateStream() async {
    if (halfSecondsTillJsonFileRead <= 0) {
      halfSecondsTillJsonFileRead--;
    } else {
      cachedJsonFile = await readJsonFile();
      halfSecondsTillJsonFileRead = 7;
    }
    List<dynamic> newData = cachedJsonFile;
    _streamController.add(newData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.system, // Use the device's theme mode
        darkTheme: ThemeData.dark(), // Dark theme
        theme: ThemeData.light(), // Light theme
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Serve - Server Manager'),
              actions: [
                ButtonBar(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await initFolder();
                        },
                        child: const Text("Update Modules")),
                    ElevatedButton(
                      onPressed: _updateStream,
                      child: const Icon(Icons.update),
                    ),
                  ],
                )
              ],
            ),
            body: StreamBuilder(
                stream: _streamController.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        var data = snapshot
                            .data![i]; // Each item is a Map<String, dynamic>

                        return ModuleWidget(
                            name: data['name'],
                            image: data['image'],
                            port: data['port'],
                            usesPath: data['usesPath'],
                            internalPath: data['internalPath'],
                            xargs: data['xargs'],
                            exec: data['exec'],
                            changablePort: data['changablePort']);
                      },
                    );
                  } else {
                    return const Text("No modules");
                  }
                })));
  }
}
