import 'dart:async';
import 'dart:io';

/**
 * Checks if podman is installed
 */
Future<bool> isPodmanInstalled() async {
  try {
    final result = await Process.run('which', ['podman']);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

/**
 * checks if the podman nextwork exists and creates it if it doesn't.
 */
Future<void> initNetwork() async {
  bool exists = await checkPodmanNetworkExists();

  if (!exists) {
    await Process.start('podman', ['network', 'create', 'serve']);
  } else {
    print("network allready exists");
  }
}

/**
 * Checks the existents of a podman network.
 */
Future<bool> checkPodmanNetworkExists() async {
  try {
    final process =
        await Process.start('podman', ['network', 'exists', 'serve']);

    return process.exitCode == 0;
  } catch (e) {
    print('Error checking network: $e');
    return false;
  }
}

/**
 * Gets the status of a podman container.
 */

Future<int> getPodmanContainerStatus(name) async {
  final result = await Process.run(
      'podman', ['ps', '-a', '--format', '"{{.Names}} {{.Status}}"']);
  final lines = result.stdout.split('\n');

  for (var line in lines) {
    //goes through all the existing containers

    String
        lineName; //gets the name of the container and removes the blank space at the front
    try {
      lineName = line.split(" ")[0].substring(1);
      if (lineName.toString() == "serve-${name}".toString()) {
        //checks if the container is in the list
        String status = line.split(' ')[1]; //gets the status of the container
        switch (status) {
          case "Up":
            return 4;

          case "Starting":
            return 3;

          case "Created\"":
            return 2;

          case "Stopping":
            return 5;

          case "Exited":
            return 2;
        }
      }
    } catch (e) {
      print(e);
    }
  }
  return 0; //no container is found in the list
}
