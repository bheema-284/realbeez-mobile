import 'package:flutter/material.dart';
import 'package:real_beez/screens/cutsom_widgets/wave_line_painter.dart';
import 'package:real_beez/utils/tab_item.dart';

class CustomTabBar extends StatefulWidget {
  final int selectedIndex;
  final List<TabItem> tabs;
  final List<GlobalKey> tabKeys;
  final List<Color> tabColors;
  final Color allTabStartColor;
  final Color allTabEndColor;
  final bool shouldUseWhiteIcons;
  final ValueChanged<int> onTabSelected;
  final double capsuleWidth;
  final double capsuleCenterX;

  const CustomTabBar({
    Key? key,
    required this.selectedIndex,
    required this.tabs,
    required this.tabKeys,
    required this.tabColors,
    required this.allTabStartColor,
    required this.allTabEndColor,
    required this.shouldUseWhiteIcons,
    required this.onTabSelected,
    required this.capsuleWidth,
    required this.capsuleCenterX,
  }) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  void _updateCapsulePosition(int index, VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Stack(
      children: [
        SizedBox(
          height: isSmallScreen ? 70 : 84,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.tabs.length, (index) {
              final isSelected = widget.selectedIndex == index;
              final Color selectedColor = index == 0 ? widget.allTabEndColor : widget.tabColors[index];
              final Color unselectedColor = widget.selectedIndex == 0 ? 
                (widget.shouldUseWhiteIcons ? Colors.white : Colors.black) : Colors.black;
              
              return GestureDetector(
                key: widget.tabKeys[index],
                onTap: () {
                  widget.onTabSelected(index);
                  _updateCapsulePosition(index, () {
                    
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 6),
                    widget.tabs[index].imagePath != null
                        ? Image.asset(widget.tabs[index].imagePath!,
                            height: isSmallScreen ? 20 : 24,
                            width: isSmallScreen ? 20 : 24,
                            color: isSelected ? selectedColor : unselectedColor)
                        : Icon(widget.tabs[index].icon!,
                            color: isSelected ? selectedColor : unselectedColor,
                            size: isSmallScreen ? 20 : 24),
                    SizedBox(height: 4),
                    Text(widget.tabs[index].label,
                        style: TextStyle(
                            color: isSelected ? selectedColor : unselectedColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: isSmallScreen ? 10 : 12)),
                    SizedBox(height: 10),
                  ],
                ),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 36),
            painter: CapsuleWaveLinePainter(
                centerX: widget.capsuleCenterX,
                capsuleWidth: widget.capsuleWidth,
                capsuleHeight: 30,
                borderRadius: 10),
          ),
        ),
      ],
    );
  }
}