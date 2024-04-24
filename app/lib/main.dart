import 'package:flutter/material.dart';

import 'package:Serve/functions/podman.dart'; //Contains all function related to podman
import 'package:Serve/functions/folderManager.dart'; //Contains all function related to managing the Serve folder

import 'package:Serve/widgets/moduleWidget.dart';

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

/**
 * The widget the gets placed in the main scene when no podman is installed.
 */
class PodmanNotInstalled extends StatelessWidget {
  const PodmanNotInstalled({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Podman is not installed on your system. Please install it to proceed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }
}

/**
 * The main app widget that contains all the module widgets.
 */
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
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
                        child: const Text("Update Modules"))
                  ],
                )
              ],
            ),
            body: StreamBuilder(
                stream: readJsonFilesStream(),
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
                            externalPath: "", //volumePaths[i]
                            xargs: data['xargs'],
                            exec: data['exec'],
                            changablePort: data['changablePort']);
                      },
                    );
                  } else {
                    return Text("No modules");
                  }
                })));
  }
}
