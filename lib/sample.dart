// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: InstamartWaveTabs(),
//   ));
// }

// class InstamartWaveTabs extends StatefulWidget {
//   const InstamartWaveTabs({super.key});

//   @override
//   State<InstamartWaveTabs> createState() => _InstamartWaveTabsState();
// }

// class _InstamartWaveTabsState extends State<InstamartWaveTabs>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _anim;

//   final List<String> tabs = [
//     "Beauty",
//     "Kids",
//     "Grocery",
//     "Fashion",
//     "Winter",
//     "Meals",
//     "Electronics",
//     "Pet Food",
//   ];

//   final List<GlobalKey> _textKeys = [];
//   final ScrollController _scrollController = ScrollController();

//   double _bumpCenter = 0;
//   double _bumpWidth = 0;

//   double _targetCenter = 0;
//   double _targetWidth = 0;

//   final double bumpHorizontalPadding = 16;
//   final double bumpHeight = 20;

//   @override
//   void initState() {
//     super.initState();

//     _tabController = TabController(length: tabs.length, vsync: this);
//     _tabController.addListener(_onTabChange);

//     _anim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 260),
//     )..addListener(() {
//         setState(() {
//           _bumpCenter = lerpDouble(_bumpCenter, _targetCenter, _anim.value)!;
//           _bumpWidth = lerpDouble(_bumpWidth, _targetWidth, _anim.value)!;
//         });
//       });

//     for (int i = 0; i < tabs.length; i++) {
//       _textKeys.add(GlobalKey());
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _moveBumpTo(2, animate: false);
//     });
//   }

//   double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

//   void _onTabChange() {
//     if (_tabController.indexIsChanging ||
//         _tabController.index != _tabController.previousIndex) {
//       _moveBumpTo(_tabController.index);
//       _scrollToIndex(_tabController.index);
//     }
//   }

//   void _scrollToIndex(int index) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final ctx = _textKeys[index].currentContext;
//         if (ctx == null) return;

//         final renderBox = ctx.findRenderObject() as RenderBox;
        
//         // Get tab center position
//         final tabCenter = renderBox.localToGlobal(Offset(renderBox.size.width / 2, 0)).dx;
//         final screenCenter = MediaQuery.of(context).size.width / 2;
        
//         // Calculate scroll offset to center the tab
//         final scrollOffset = tabCenter - screenCenter;
//         final currentScroll = _scrollController.offset;
//         double targetScroll = currentScroll + scrollOffset;

//         // Clamp scroll position
//         final maxScroll = _scrollController.position.maxScrollExtent;
//         final minScroll = _scrollController.position.minScrollExtent;
//         targetScroll = targetScroll.clamp(minScroll, maxScroll);

//         if ((targetScroll - currentScroll).abs() > 1) {
//           _scrollController.animateTo(
//             targetScroll,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         }
//       } catch (_) {}
//     });
//   }

//   void _moveBumpTo(int index, {bool animate = true}) {
//     try {
//       final ctx = _textKeys[index].currentContext;
//       if (ctx == null) return;

//       final renderBox = ctx.findRenderObject() as RenderBox;
      
//       // Get tab center position relative to screen
//       final tabCenter = renderBox.localToGlobal(Offset(renderBox.size.width / 2, 0)).dx;
//       final width = renderBox.size.width + bumpHorizontalPadding * 2;

//       _targetCenter = tabCenter;
//       _targetWidth = width;

//       if (!animate) {
//         _bumpCenter = _targetCenter;
//         _bumpWidth = _targetWidth;
//         setState(() {});
//         return;
//       }

//       _anim.reset();
//       _anim.forward();
//     } catch (_) {}
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _anim.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F9FB),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 100,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // TabBar
//                 Positioned.fill(
//                   child: SingleChildScrollView(
//                     controller: _scrollController,
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     child: SizedBox(
//                       height: 100,
//                       child: TabBar(
//                         controller: _tabController,
//                         isScrollable: true,
//                         indicator: const BoxDecoration(),
//                         indicatorColor: Colors.transparent,
//                         dividerColor: Colors.transparent,
//                         overlayColor: MaterialStateProperty.all(
//                           Colors.transparent,
//                         ),
//                         labelPadding: const EdgeInsets.symmetric(horizontal: 16),
//                         tabs: List.generate(tabs.length, (i) {
//                           return Tab(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.shopping_bag_outlined,
//                                     size: 22,
//                                     color: _tabController.index == i
//                                         ? Colors.black
//                                         : Colors.grey.shade600,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Container(
//                                     key: _textKeys[i],
//                                     child: Text(
//                                       tabs[i],
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                         color: _tabController.index == i
//                                             ? Colors.black
//                                             : Colors.grey.shade700,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Capsule bump - ALWAYS VISIBLE like Swiggy
//                 Positioned(
//                   top: 53,
//                   left: 0,
//                   right: 0,
//                   child: CustomPaint(
//                     painter: CapsuleWaveLinePainter(
//                       centerX: _bumpCenter,
//                       capsuleWidth: _bumpWidth,
//                       capsuleHeight: bumpHeight,
//                       borderRadius: 12,
//                     ),
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width,
//                       height: bumpHeight + 8,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Tab content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: tabs
//                   .map((t) => Center(
//                         child: Text(
//                           "$t content",
//                           style: const TextStyle(fontSize: 24),
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CapsuleWaveLinePainter extends CustomPainter {
//   final double centerX;
//   final double capsuleWidth;
//   final double capsuleHeight;
//   final double borderRadius;

//   CapsuleWaveLinePainter({
//     required this.centerX,
//     required this.capsuleWidth,
//     required this.capsuleHeight,
//     this.borderRadius = 0,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Create a shader for fading effect at the ends
//     final gradient = LinearGradient(
//       colors: [
//         Colors.black.withOpacity(0.0),
//         Colors.black.withOpacity(0.25),
//         Colors.black.withOpacity(0.25),
//         Colors.black.withOpacity(0.0),
//       ],
//       stops: const [0.0, 0.1, 0.9, 1.0],
//     ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

//     final paint = Paint()
//       ..shader = gradient
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.4;

//     final double left = centerX - capsuleWidth / 2;
//     final double right = centerX + capsuleWidth / 2;
//     final double top = 0;
//     final double bottom = capsuleHeight;

//     final path = Path();

//     // Start from left edge at bottom
//     path.moveTo(0, bottom);

//     // Draw bottom line from left edge to capsule with rounded connection
//     path.lineTo(left - borderRadius, bottom);
    
//     // Rounded connection at left side
//     path.quadraticBezierTo(
//       left, bottom,
//       left, bottom - borderRadius,
//     );

//     // Draw left vertical line
//     path.lineTo(left, top + borderRadius);

//     // Draw rounded top-left corner
//     path.quadraticBezierTo(
//       left, top,
//       left + borderRadius, top,
//     );

//     // Draw top line
//     path.lineTo(right - borderRadius, top);

//     // Draw rounded top-right corner
//     path.quadraticBezierTo(
//       right, top,
//       right, top + borderRadius,
//     );

//     // Draw right vertical line
//     path.lineTo(right, bottom - borderRadius);

//     // Rounded connection at right side
//     path.quadraticBezierTo(
//       right, bottom,
//       right + borderRadius, bottom,
//     );

//     // Draw bottom line from capsule to right edge
//     path.lineTo(size.width, bottom);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CapsuleWaveLinePainter oldDelegate) {
//     return oldDelegate.centerX != centerX ||
//         oldDelegate.capsuleWidth != capsuleWidth ||
//         oldDelegate.capsuleHeight != capsuleHeight ||
//         oldDelegate.borderRadius != borderRadius;
//   }
// }