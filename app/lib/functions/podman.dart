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
