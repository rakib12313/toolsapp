import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ToolModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final Color iconBackgroundColor;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.iconBackgroundColor = AppTheme.primaryBlue,
  });
}

final List<ToolModel> allTools = [
  // Image Tools
  ToolModel(
    id: 'image_resizer',
    name: 'Image Resizer',
    description: 'Resize images by percentage or dimensions',
    icon: Icons.photo_size_select_large,
    category: 'Image',
  ),
  ToolModel(
    id: 'image_compressor',
    name: 'Image Compressor',
    description: 'Compress images to reduce file size',
    icon: Icons.compress,
    category: 'Image',
  ),
  ToolModel(
    id: 'image_converter',
    name: 'Image Converter',
    description: 'Convert images between formats',
    icon: Icons.transform,
    category: 'Image',
  ),
  ToolModel(
    id: 'images_to_pdf',
    name: 'Images to PDF',
    description: 'Convert multiple images to PDF',
    icon: Icons.picture_as_pdf,
    category: 'Image',
  ),
  // PDF Tools
  ToolModel(
    id: 'pdf_merger',
    name: 'PDF Merger',
    description: 'Merge multiple PDFs into one',
    icon: Icons.merge_type,
    category: 'PDF',
  ),
  ToolModel(
    id: 'pdf_to_images',
    name: 'PDF to Images',
    description: 'Convert PDF pages to images',
    icon: Icons.image,
    category: 'PDF',
  ),
  ToolModel(
    id: 'pdf_editor',
    name: 'PDF Editor',
    description: 'Rearrange, rotate, delete pages',
    icon: Icons.edit_document,
    category: 'PDF',
  ),
  // Video Tools
  ToolModel(
    id: 'video_converter',
    name: 'Video Converter',
    description: 'Convert between video formats',
    icon: Icons.video_library,
    category: 'Video',
  ),
  ToolModel(
    id: 'video_compressor',
    name: 'Video Compressor',
    description: 'Reduce video file size',
    icon: Icons.video_settings,
    category: 'Video',
  ),
  ToolModel(
    id: 'video_trimmer',
    name: 'Video Trimmer',
    description: 'Trim video start and end',
    icon: Icons.content_cut,
    category: 'Video',
  ),
  // Audio Tools
  ToolModel(
    id: 'audio_extractor',
    name: 'Audio Extractor',
    description: 'Extract audio from video',
    icon: Icons.audiotrack,
    category: 'Audio',
  ),
];