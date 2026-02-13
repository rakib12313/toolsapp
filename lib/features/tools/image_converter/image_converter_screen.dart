import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() => _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  String _targetFormat = 'PNG';
  String? _outputPath;

  final List<String> _formats = ['PNG', 'JPEG', 'BMP', 'GIF'];

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        _outputPath = null;
      });
    }
  }

  Future<void> _convertImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String outputPath;
      List<int> encoded;

      switch (_targetFormat.toLowerCase()) {
        case 'png':
          outputPath = '${directory.path}/converted_$timestamp.png';
          encoded = img.encodePng(image);
          break;
        case 'jpeg':
        case 'jpg':
          outputPath = '${directory.path}/converted_$timestamp.jpg';
          encoded = img.encodeJpg(image, quality: 90);
          break;

        case 'bmp':
          outputPath = '${directory.path}/converted_$timestamp.bmp';
          encoded = img.encodeBmp(image);
          break;
        case 'gif':
          outputPath = '${directory.path}/converted_$timestamp.gif';
          encoded = img.encodeGif(image);
          break;
        default:
          throw Exception('Unsupported format');
      }

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(encoded);

      setState(() {
        _outputPath = outputPath;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image converted to $_targetFormat!')),
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
        title: const Text('Image Converter'),
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
              const Text(
                'Target Format',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                children: _formats.map((format) {
                  return ChoiceChip(
                    label: Text(format),
                    selected: _targetFormat == format,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _targetFormat = format;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _convertImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.transform),
                label: Text(_isProcessing ? 'Converting...' : 'Convert to $_targetFormat'),
              ),
            ],
            
            if (_outputPath != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Converted to $_targetFormat!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saved to: $_outputPath',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        textAlign: TextAlign.center,
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