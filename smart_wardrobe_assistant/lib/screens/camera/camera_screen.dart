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
Future<void> _initializeCamera() async {
if (widget.cameras.isEmpty) {
return;
}

_controller = CameraController(
widget.cameras[0],
ResolutionPreset.high,
enableAudio: false,
);

await _controller!.initialize();

if (!mounted) return;

setState(() {
_isCameraInitialized = true;
});
}
Future<void> _captureImage() async {
if (_controller == null ||
!_controller!.value.isInitialized ||
_isCapturing) {
return;
}

setState(() {
_isCapturing = true;
});

try {
final XFile image = await _controller!.takePicture();

if (!mounted) return;

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => ImagePreviewScreen(
  imagePath: image.path,
),
),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Failed to capture image: $e'),
),
);
}

setState(() {
_isCapturing = false;
});
}

@override
void dispose() {
_controller?.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),

    appBar: AppBar(
      title: const Text("Camera"),
      backgroundColor: const Color(0xFF4F46E5),
    ),

    body: _isCameraInitialized
        ? CameraPreview(_controller!)
        : const Center(
      child: CircularProgressIndicator(),
    ),

    floatingActionButton: Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          FloatingActionButton(
            heroTag: "gallery",
            backgroundColor: const Color(0xFF14B8A6),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GalleryScreen(),
                ),
              );
            },
            child: const Icon(Icons.photo),
          ),

          FloatingActionButton(
            heroTag: "camera",
            backgroundColor: const Color(0xFF4F46E5),
            onPressed: _captureImage,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    ),
  );
}
}
