import 'package:flutter/material.dart';
//Functinos
import 'package:Serve/functions/podman.dart'; //Contains all function related to podman

void main() async {
  if (!await isPodmanInstalled()) {
    runApp(const PodmanNotInstalled()); //opens the "podman not found" window
  } else {}
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
