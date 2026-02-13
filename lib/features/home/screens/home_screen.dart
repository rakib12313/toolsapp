import 'package:flutter/material.dart';
import '../../../models/tool_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../tools/image_resizer/image_resizer_screen.dart';
import '../../tools/image_compressor/image_compressor_screen.dart';
import '../../tools/image_converter/image_converter_screen.dart';
import '../../tools/images_to_pdf/images_to_pdf_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth < 400) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    } else if (screenWidth < 600) {
      crossAxisCount = 3;
      childAspectRatio = 1.15;
    } else if (screenWidth < 900) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    } else if (screenWidth < 1400) {
      crossAxisCount = 5;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 6;
      childAspectRatio = 1.2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToolBox Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedCategorySection('Image Tools', 'Image', crossAxisCount, childAspectRatio, 0),
            const SizedBox(height: 20),
            _buildAnimatedCategorySection('PDF Tools', 'PDF', crossAxisCount, childAspectRatio, 1),
            const SizedBox(height: 20),
            _buildAnimatedCategorySection('Video Tools', 'Video', crossAxisCount, childAspectRatio, 2),
            const SizedBox(height: 20),
            _buildAnimatedCategorySection('Audio Tools', 'Audio', crossAxisCount, childAspectRatio, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCategorySection(String title, String category, int crossAxisCount, double childAspectRatio, int sectionIndex) {
    final tools = allTools.where((tool) => tool.category == category).toList();
    final delay = sectionIndex * 0.15;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              delay + 0.5,
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        
        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              delay + 0.4,
              curve: Curves.easeOut,
            ),
          ),
        );
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildCategorySection(title, tools, crossAxisCount, childAspectRatio, sectionIndex),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<ToolModel> tools, int crossAxisCount, double childAspectRatio, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return ToolCard(
              tool: tools[index],
              animationController: _animationController,
              index: index + (sectionIndex * 10),
            );
          },
        ),
      ],
    );
  }
}

class ToolCard extends StatefulWidget {
  final ToolModel tool;
  final AnimationController animationController;
  final int index;

  const ToolCard({
    super.key,
    required this.tool,
    required this.animationController,
    required this.index,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final delay = 0.1 + (widget.index * 0.03);
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(
              delay,
              delay + 0.3,
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        
        return Transform.scale(
          scale: _isPressed ? 0.95 : scaleAnimation.value,
          child: Opacity(
            opacity: scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            setState(() => _isPressed = false);
            _navigateToTool(widget.tool);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.tool.icon,
                    color: AppTheme.primaryLight,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    widget.tool.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 1),
                Flexible(
                  child: Text(
                    widget.tool.description,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTool(ToolModel tool) {
    Widget? screen;
    
    switch (tool.id) {
      case 'image_resizer':
        screen = const ImageResizerScreen();
        break;
      case 'image_compressor':
        screen = const ImageCompressorScreen();
        break;
      case 'image_converter':
        screen = const ImageConverterScreen();
        break;
      case 'images_to_pdf':
        screen = const ImagesToPdfScreen();
        break;
      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${tool.name} coming soon!')),
          );
        }
        return;
    }
    
    if (screen != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => screen!,
        ),
      );
    }
  }
}
