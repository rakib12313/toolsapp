import 'package:flutter/material.dart';
import '../../../models/tool_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../tools/image_resizer/image_resizer_screen.dart';
import '../../tools/image_compressor/image_compressor_screen.dart';
import '../../tools/image_converter/image_converter_screen.dart';
import '../../tools/images_to_pdf/images_to_pdf_screen.dart';

class ResponsiveSizes {
  final double iconSize;
  final double titleSize;
  final double descSize;
  final double cardPadding;
  final double iconPadding;
  final double spacing;
  final int crossAxisCount;
  final double childAspectRatio;

  ResponsiveSizes({
    required this.iconSize,
    required this.titleSize,
    required this.descSize,
    required this.cardPadding,
    required this.iconPadding,
    required this.spacing,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  factory ResponsiveSizes.fromWidth(double width) {
    // Small mobile phones
    if (width < 360) {
      return ResponsiveSizes(
        iconSize: 22,
        titleSize: 11,
        descSize: 9,
        cardPadding: 8,
        iconPadding: 8,
        spacing: 4,
        crossAxisCount: 2,
        childAspectRatio: 0.85,
      );
    }
    // Standard mobile phones
    else if (width < 480) {
      return ResponsiveSizes(
        iconSize: 24,
        titleSize: 12,
        descSize: 10,
        cardPadding: 10,
        iconPadding: 10,
        spacing: 6,
        crossAxisCount: 2,
        childAspectRatio: 0.9,
      );
    }
    // Large phones / Small tablets
    else if (width < 600) {
      return ResponsiveSizes(
        iconSize: 26,
        titleSize: 13,
        descSize: 11,
        cardPadding: 12,
        iconPadding: 10,
        spacing: 8,
        crossAxisCount: 3,
        childAspectRatio: 0.95,
      );
    }
    // Tablets
    else if (width < 900) {
      return ResponsiveSizes(
        iconSize: 28,
        titleSize: 14,
        descSize: 12,
        cardPadding: 14,
        iconPadding: 12,
        spacing: 10,
        crossAxisCount: 4,
        childAspectRatio: 1.0,
      );
    }
    // Small desktop / Large tablets
    else if (width < 1200) {
      return ResponsiveSizes(
        iconSize: 30,
        titleSize: 15,
        descSize: 12,
        cardPadding: 16,
        iconPadding: 12,
        spacing: 12,
        crossAxisCount: 5,
        childAspectRatio: 1.05,
      );
    }
    // Desktop
    else {
      return ResponsiveSizes(
        iconSize: 32,
        titleSize: 16,
        descSize: 13,
        cardPadding: 18,
        iconPadding: 14,
        spacing: 14,
        crossAxisCount: 6,
        childAspectRatio: 1.1,
      );
    }
  }
}

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
    final sizes = ResponsiveSizes.fromWidth(screenWidth);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToolBox Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(sizes.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedCategorySection('Image Tools', 'Image', sizes, 0),
            SizedBox(height: sizes.spacing * 1.5),
            _buildAnimatedCategorySection('PDF Tools', 'PDF', sizes, 1),
            SizedBox(height: sizes.spacing * 1.5),
            _buildAnimatedCategorySection('Video Tools', 'Video', sizes, 2),
            SizedBox(height: sizes.spacing * 1.5),
            _buildAnimatedCategorySection('Audio Tools', 'Audio', sizes, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCategorySection(String title, String category, ResponsiveSizes sizes, int sectionIndex) {
    final tools = allTools.where((tool) => tool.category == category).toList();
    final delay = sectionIndex * 0.1;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              delay + 0.4,
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
              delay + 0.3,
              curve: Curves.easeOut,
            ),
          ),
        );
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildCategorySection(title, tools, sizes),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<ToolModel> tools, ResponsiveSizes sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: sizes.titleSize + 2,
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: sizes.crossAxisCount,
            childAspectRatio: sizes.childAspectRatio,
            crossAxisSpacing: sizes.spacing.toDouble(),
            mainAxisSpacing: sizes.spacing.toDouble(),
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return ToolCard(
              tool: tools[index],
              animationController: _animationController,
              index: index,
              sizes: sizes,
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
  final ResponsiveSizes sizes;

  const ToolCard({
    super.key,
    required this.tool,
    required this.animationController,
    required this.index,
    required this.sizes,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 0.05;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sizes = widget.sizes;
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(
              delay,
              delay + 0.2,
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
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceVariantDark : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              setState(() => _isPressed = false);
              _navigateToTool(widget.tool);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(sizes.cardPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(sizes.iconPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.tool.icon,
                      color: colorScheme.primary,
                      size: sizes.iconSize,
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    widget.tool.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: sizes.titleSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sizes.spacing * 0.5),
                  Text(
                    widget.tool.description,
                    style: TextStyle(
                      fontSize: sizes.descSize,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
            SnackBar(
              content: Text('${tool.name} coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
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
