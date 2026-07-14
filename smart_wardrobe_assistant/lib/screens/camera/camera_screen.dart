import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'gallery_screen.dart';
import 'image_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
CameraController? _controller;
bool _isCameraInitialized = false;
bool _isCapturing = false;

@override
void initState() {
super.initState();
_initializeCamera();
}
