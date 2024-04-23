import 'package:flutter/material.dart';

import 'package:Serve/functions/podman.dart'; //Contains all function related to podman

List modules = []; //The data of the modules
void main() async {
  if (!await isPodmanInstalled()) {
    runApp(const PodmanNotInstalled()); //opens the "podman not found" window
  } else {
    runApp(App());
  }
}

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
                      onPressed: () {
                        setState(() {
                          modules.add(Text("Test"));
                        });
                      },
                      child: const Text("Reload")),
                ],
              )
            ],
          ),
          body: ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, i) {
              return Card(
                child: Text(i.toString()),
              );
            },
          )),
    );
  }
}
