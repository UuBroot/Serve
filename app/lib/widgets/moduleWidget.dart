import 'package:Serve/functions/podman.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:Serve/functions/folderManager.dart';

int state =
    0; //0 nonExisting | 1 creating | 2 stopped | 3 starting | 4 running | 5 stopping | 6 deleting

class ModuleWidget extends StatefulWidget {
  //Initialises all the variables that are given by main.dart
  final String name;
  final String image;
  final String port;
  final bool usesPath;
  final String internalPath;
  final String externalPath;
  final String xargs;
  final String exec;
  final bool changablePort;

  //sets all the variables that are given by main.dart
  const ModuleWidget(
      {super.key,
      required this.name,
      required this.image,
      required this.port,
      required this.usesPath,
      required this.internalPath,
      required this.externalPath,
      required this.xargs,
      required this.exec,
      required this.changablePort});

  @override
  State<ModuleWidget> createState() => _ModuleWidgetState();
}

class _ModuleWidgetState extends State<ModuleWidget> {
  /**
   * Updates the container status and the button variable.
   */
  void updateState(name) async {
    state = await getPodmanContainerStatus(name);
  }

  final TextEditingController _pathTextfieldController =
      TextEditingController(); //Text controller for the potential input field
  final TextEditingController _portTextfieldController =
      TextEditingController(); //Text controller for the port input field

  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    updateState(widget.name); //updates the state variable

    _portTextfieldController.text = widget.port.split(':')[0].toString();

    //writePortToConfig("php", "234");
    bool inputDisabled = false;
    bool changablePort = !inputDisabled &&
        widget
            .changablePort; //if the port can be changed in the ui or not //after the button text switch case, because of the inputDisabled variable

    String buttonText = "";
    switch (state) {
      case 0:
        buttonText = "Create";

      case 1:
        buttonText = "Creating ...";

      case 2:
        buttonText = "Start";

      case 3:
        buttonText = "Starting ...";

      case 4:
        buttonText = "Stop";

      case 5:
        buttonText = "Stopping";

      case 6:
        buttonText = "Resetting ...";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    //TITEL
                    Text(
                      widget.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Row(
                          children: [
                            //OPEN IN BROWSER BUTTON
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
                                onPressed: () {
                                  launchURL(
                                      "http://localhost:${_portTextfieldController.text}");
                                },
                                child: Text("Open in browser")),
                          ],
                        ),
                        const SizedBox(width: 10),
                        //RESET BUTTON
                        ElevatedButton(
                            onPressed: () {
                              //reset();
                            },
                            child: const Text("Reset")),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    //PORT INPUT
                    Expanded(
                      child: SizedBox(
                        width: 250, // Set the width
                        height: 35, // Set the height
                        child: TextField(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                          ),
                          controller: _portTextfieldController,
                          readOnly: !changablePort,
                          style: TextStyle(fontSize: 20),
                          maxLines: 1, // Ensure it's a single line TextField
                        ),
                      ),
                    ),
                    const SizedBox(width: 1050),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switch (state) {
                            case 0:
                              //create();
                              break;
                            case 1:
                              print("still creating");
                              break;
                            case 2:
                              //start();
                              break;
                            case 3:
                              print("still starting");
                              break;
                            case 4:
                              //stop();
                              break;
                            case 5:
                              print("still stopping");
                              break;
                            case 6:
                              print("still resetting");
                              break;
                          }
                        });
                      },
                      child: Text(buttonText),
                    ),
                  ],
                ),
                if (widget.usesPath)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pathTextfieldController,
                          readOnly: inputDisabled,
                          decoration: const InputDecoration(
                            labelText: 'Path',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: inputDisabled
                            ? null
                            : () {
                                setState(() async {
                                  final String? path =
                                      "await getDirectoryPath()";
                                  if (path != null) {
                                    // Use the selected directory path
                                    _pathTextfieldController.text = path;
                                  } else {
                                    // User canceled the picker
                                    print('User canceled the picker');
                                  }
                                });
                              },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey; // Change color when disabled
                            }
                            return Theme.of(context)
                                .colorScheme
                                .background; // Default color when enabled
                          }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.white.withOpacity(
                                  0.5); // Change text color when disabled
                            }
                            return Theme.of(context)
                                .colorScheme
                                .primary; // Default text color when enabled
                          }),
                        ),
                        child: const Text('Select'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * Launches the url in the browser
 */
Future<void> launchURL(String url) async {
  //TODO:find alternative to depricated feature
  // ignore: deprecated_member_use
  if (await canLaunch(url)) {
    // ignore: deprecated_member_use
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
