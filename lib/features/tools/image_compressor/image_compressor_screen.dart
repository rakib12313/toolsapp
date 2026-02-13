import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  int _quality = 80;
  int? _originalSize;
  int? _compressedSize;
  String? _outputPath;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final stat = await file.stat();
      
      setState(() {
        _selectedImage = file;
        _originalSize = stat.size;
        _compressedSize = null;
        _outputPath = null;
      });
    }
  }

  Future<void> _compressImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = img.encodeJpg(image, quality: _quality);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressed);

      final stat = await outputFile.stat();

      setState(() {
        _compressedSize = stat.size;
        _outputPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image compressed and saved!')),
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compressor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
            ),
            const SizedBox(height: 24),
            
            if (_selectedImage != null) ...[
              if (_originalSize != null)
                Text(
                  'Original Size: ${_formatSize(_originalSize!)}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              
              const Text(
                'Compression Quality',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Text('Quality:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _quality.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _quality.toString(),
                      onChanged: (value) {
                        setState(() {
                          _quality = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$_quality%'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _compressImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.compress),
                label: Text(_isProcessing ? 'Compressing...' : 'Compress Image'),
              ),
            ],
            
            if (_compressedSize != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Compression Complete!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Original: ${_formatSize(_originalSize!)}'),
                      Text('Compressed: ${_formatSize(_compressedSize!)}'),
                      Text(
                        'Saved: ${_formatSize(_originalSize! - _compressedSize!)} (${((1 - _compressedSize! / _originalSize!) * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
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