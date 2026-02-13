import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HistoryItem {
  final String id;
  final String toolName;
  final IconData toolIcon;
  final String inputFile;
  final String outputFile;
  final DateTime timestamp;
  final int? inputSize;
  final int? outputSize;
  final String status;

  HistoryItem({
    required this.id,
    required this.toolName,
    required this.toolIcon,
    required this.inputFile,
    required this.outputFile,
    required this.timestamp,
    this.inputSize,
    this.outputSize,
    required this.status,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  final List<HistoryItem> _historyItems = [];
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _historyItems.addAll([
        HistoryItem(
          id: '1',
          toolName: 'Image Resizer',
          toolIcon: Icons.photo_size_select_large,
          inputFile: 'photo.jpg',
          outputFile: 'photo_resized.jpg',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          inputSize: 2048000,
          outputSize: 1024000,
          status: 'completed',
        ),
        HistoryItem(
          id: '2',
          toolName: 'PDF Merger',
          toolIcon: Icons.merge_type,
          inputFile: 'doc1.pdf, doc2.pdf',
          outputFile: 'merged.pdf',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          inputSize: 5120000,
          outputSize: 5200000,
          status: 'completed',
        ),
      ]);
    });
    _animationController.forward();
  }

  List<HistoryItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _historyItems;
    return _historyItems.where((item) {
      return item.toolName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.inputFile.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  Future<void> _openFileLocation(String outputFile) async {
    try {
      // For sample data, use app's documents directory
      final dir = await getApplicationDocumentsDirectory();
      final dirPath = dir.path;
      
      // Try to open the directory using platform channel or url_launcher
      // For now, show a snackbar with the path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File location: $dirPath'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: dirPath));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shareFile(String outputFile) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showClearHistoryDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildAnimatedHistoryItem(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your processed files will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHistoryItem(HistoryItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 50),
            child: child,
          ),
        );
      },
      child: _buildHistoryItem(item),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.toolIcon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          item.toolName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDate(item.timestamp)),
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Input:', item.inputFile),
                const SizedBox(height: 4),
                _buildInfoRow('Output:', item.outputFile),
                const SizedBox(height: 4),
                _buildInfoRow('Input Size:', _formatFileSize(item.inputSize)),
                const SizedBox(height: 4),
                _buildInfoRow('Output Size:', _formatFileSize(item.outputSize)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openFileLocation(item.outputFile),
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: const Text('Open Location'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareFile(item.outputFile),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _historyItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
