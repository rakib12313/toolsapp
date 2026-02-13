import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class ImageResizerScreen extends StatefulWidget {
  const ImageResizerScreen({super.key});

  @override
  State<ImageResizerScreen> createState() => _ImageResizerScreenState();
}

class _ImageResizerScreenState extends State<ImageResizerScreen> {
  File? _selectedImage;
  String? _previewPath;
  bool _isProcessing = false;
  double _width = 800;
  double _height = 600;
  bool _maintainAspectRatio = true;
  double _quality = 85;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
      _loadImageDimensions();
    }
  }

  void _loadImageDimensions() async {
    if (_selectedImage == null) return;
    
    final bytes = await _selectedImage!.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      setState(() {
        _width = image.width.toDouble();
        _height = image.height.toDouble();
      });
    }
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      final bytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      // Resize image
      final resized = img.copyResize(
        image,
        width: _width.toInt(),
        height: _maintainAspectRatio ? null : _height.toInt(),
      );

      // Get output directory
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save resized image
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(resized, quality: _quality.toInt()));

      setState(() {
        _previewPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $outputPath')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Resizer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage == null
                  ? const Center(child: Text('No image selected'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Pick Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
            ),
            const SizedBox(height: 24),
            
            // Resize Controls
            if (_selectedImage != null) ...[
              const Text(
                'Resize Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Width Slider
              Row(
                children: [
                  const Text('Width:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _width,
                      min: 100,
                      max: 4000,
                      divisions: 39,
                      label: _width.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _width = value;
                          if (_maintainAspectRatio) {
                            // Calculate height based on aspect ratio
                          }
                        });
                      },
                    ),
                  ),
                  Text(_width.toInt().toString()),
                ],
              ),
              
              // Height Slider
              Row(
                children: [
                  const Text('Height:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _height,
                      min: 100,
                      max: 4000,
                      divisions: 39,
                      label: _height.toInt().toString(),
                      onChanged: _maintainAspectRatio
                          ? null
                          : (value) {
                              setState(() {
                                _height = value;
                              });
                            },
                    ),
                  ),
                  Text(_height.toInt().toString()),
                ],
              ),
              
              // Maintain Aspect Ratio
              CheckboxListTile(
                title: const Text('Maintain Aspect Ratio'),
                value: _maintainAspectRatio,
                onChanged: (value) {
                  setState(() {
                    _maintainAspectRatio = value ?? true;
                  });
                },
              ),
              
              // Quality Slider
              Row(
                children: [
                  const Text('Quality:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _quality,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _quality.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _quality = value;
                        });
                      },
                    ),
                  ),
                  Text('${_quality.toInt()}%'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Process Button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _resizeImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.crop),
                label: Text(_isProcessing ? 'Processing...' : 'Resize Image'),
              ),
            ],
            
            // Preview Result
            if (_previewPath != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Result Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_previewPath!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}