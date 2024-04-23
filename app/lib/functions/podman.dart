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
