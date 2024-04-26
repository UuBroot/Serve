import 'package:Serve/functions/podman.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';
import 'package:process_run/shell.dart';

//int state = 0;

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
  final TextEditingController _pathTextfieldController =
      TextEditingController(); //Text controller for the potential input field
  final TextEditingController _portTextfieldController =
      TextEditingController(); //Text controller for the port input field

  bool firstRun = true;

  /**
   * Creates the container.
   */
  void create() async {
    if (_pathTextfieldController.text.isNotEmpty &&
            _portTextfieldController.text.isNotEmpty ||
        widget.usesPath == false) {
      var shell = Shell();

      try {
        var results = await shell
            .run(makeCreateContainerCommand()); //Trys to run create command

        for (var result in results) {
          // Check if the command was successful
          if (result.exitCode == 0) {
            if (widget.exec.isNotEmpty) {
              //command();
            }

            start(); //starts the container after creation
          } else {
            print("Command error: ${result.stderr}");
          }
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("no path");
      //showError(context, "No path was given");
    }
  }

  /**
   * Builds the command needed to create the container.
   */
  String makeCreateContainerCommand() {
    List<String> command = ['podman', 'create', '--replace'];

    //network
    command.add('--network');
    command.add('serve');

    //path
    if (widget.usesPath) {
      command.add('-v');
      command.add('${_pathTextfieldController.text}:${widget.internalPath}');
    }

    //name
    command.add('--name');
    command.add('serve-${widget.name}');

    //port
    print("port:" + widget.port);
    if (widget.port != "" && widget.port != "0") {
      command.add('--publish');
      command.add(_portTextfieldController.text +
          ":" +
          widget.port.split(':')[1].toString());
    }

    //xargs
    String xargs = widget.xargs;
    if (widget.xargs.contains('|') || widget.xargs.contains(';')) {
      //Check if user doesn't parse other commands
      xargs =
          ""; //TODO: somehow salvage the arguments without parsing other commands
    } else {
      command.add(xargs);
    }

    //image
    command.add(widget.image);

    //builds the string from the list
    String commandString = "";
    for (int i = 0; i < command.length; i++) {
      commandString += command[i].toString();
      commandString += " ";
    }

    print(commandString);
    return commandString;
  }

  /**
   * Resets/Removes a container.
   */
  void reset() async {
    bool confirm =
        await showResetConfirmation(context); //opens a confirmation dialog

    if (confirm) {
      var shell = Shell();

      try {
        var results = await shell.run(
            'podman rm -f serve-${widget.name}'); //tries to reset/delete the container

        for (var result in results) {
          if (result.exitCode == 0) {
            print("Command output: ${result.stdout}");
          } else {
            print("Command error: ${result.stderr}");
          }
        }

        if (widget.usesPath) {
          //if the container uses a path, it gets reset
          _pathTextfieldController.text = "";
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("won't reset");
    }
  }

  /**
   * Popup asking the user if they really want to delete the container.
   */
  Future<bool> showResetConfirmation(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reset'),
          content: Text('Are you sure you want to reset this container?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    return Future.value(result);
  }

  /**
   * Starts the podman container.
   */
  void start() async {
    var shell = Shell();
    // Run the command
    try {
      shell.run(
          'podman start serve-${widget.name}'); //tries to start the container
    } catch (e) {
      //showError(context,"Could not stop container. Check if the port is in use, or run the programm using the terminal to check for errors.");
      print("Command error: ${e}");
    }
  }

  /**
   * Stops the podman container
   */

  void stop() async {
    var shell = Shell();

    try {
      shell.run(
          'podman stop serve-${widget.name}'); //tries to stop the container
    } catch (e) {
      print("Error running command: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _portTextfieldController.text = widget.port.split(':')[0].toString();

    //writePortToConfig("php", "234");
    bool inputDisabled = false;
    bool changablePort = !inputDisabled &&
        widget
            .changablePort; //if the port can be changed in the ui or not //after the button text switch case, because of the inputDisabled variable

    return FutureBuilder(
        future: getPodmanContainerStatus(widget
            .name), //0 nonExisting | 1 creating | 2 stopped | 3 starting | 4 running | 5 stopping | 6 deleting
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            //showError(context, "wip error");
          } else if (snapshot.hasData) {
            final state = snapshot.data;
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
                buttonText = "Stopping ...";

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
                                          borderRadius:
                                              BorderRadius.circular(5.0),
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
                                      reset();
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                  ),
                                  controller: _portTextfieldController,
                                  readOnly: !changablePort,
                                  style: TextStyle(fontSize: 20),
                                  maxLines:
                                      1, // Ensure it's a single line TextField
                                ),
                              ),
                            ),
                            const SizedBox(width: 1050),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  switch (state) {
                                    case 0:
                                      create();
                                    case 1:
                                      print("still creating");
                                    case 2:
                                      start();
                                    case 3:
                                      print("still starting");
                                      break;
                                    case 4:
                                      stop();
                                    case 5:
                                      print("still stopping");
                                    case 6:
                                      print("still resetting");
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
                                              await getDirectoryPath();
                                          if (path != null) {
                                            // Use the selected directory path
                                            _pathTextfieldController.text =
                                                path;
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
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors
                                          .grey; // Change color when disabled
                                    }
                                    return Theme.of(context)
                                        .colorScheme
                                        .background; // Default color when enabled
                                  }),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
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
          } else {
            print("wip err");
          }
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ))));
        });
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
}
