import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:real_beez/screens/cutsom_widgets/swipe_cards.dart';
import 'package:real_beez/screens/homescreen/widgets/capsule_wave_painter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:real_beez/property_cards.dart'; 
import 'package:real_beez/screens/bottom_bar_screens/ai.dart' as ai; 
import 'package:real_beez/screens/bottom_bar_screens/emi_calculator.dart'; 
import 'package:real_beez/screens/homescreen/widgets/other_tabs_content.dart'; 
import 'package:real_beez/screens/homescreen/widgets/must_visit_section.dart';
import 'package:real_beez/screens/homescreen/widgets/featured_sites_section.dart';
import 'package:real_beez/screens/premium_screens/premium_plan.dart' as premium_screen; 
import 'package:real_beez/screens/cutsom_widgets/custom_bottom_bar.dart'; 
import 'package:real_beez/screens/profile_screens/profile.dart'; 
import 'package:real_beez/screens/top_bar_screens/notification_screen.dart'; 
import 'package:real_beez/screens/top_bar_screens/wishlist_screen.dart'; 
import 'package:real_beez/utils/tab_item.dart'; 
import 'package:real_beez/utils/app_colors.dart'; 
import './widgets/top_app_bar.dart'; 
import './widgets/special_offers_section.dart'; 
import './widgets/sticky_map_button.dart'; 

void main() { 
  runApp(MaterialApp( 
    home: HomeScreen(), 
    debugShowCheckedModeBanner: false, 
  )); 
} 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override 
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState(); 
} 

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin { 
  int selectedIndex = 0; 
  int bottomNavIndex = 0; 
  int selectedBuilderIndex = 0; 
  bool _isTextVisible = true; 
  Timer? _blinkTimer; 
  final ScrollController _scrollController = ScrollController(); 
  double _scrollOffset = 0.0; 
  int _currentSpecialOfferPage = 0; 
  int _currentRecommendedPage = 0; 
  bool _isLoading = true;

  late TabController _tabController;
  late AnimationController _anim;

  final List<TabItem> tabs = [ 
    TabItem(imagePath: 'assets/icons/all.png', label: 'All'), 
    TabItem(imagePath: 'assets/icons/apartment.png', label: 'Apartment'), 
    TabItem(imagePath: 'assets/icons/villas.png', label: 'Villas'), 
    TabItem(imagePath: 'assets/icons/farmland.png', label: 'Farmlands'), 
    TabItem(imagePath: 'assets/icons/open_plots.png', label: 'Open Plots'), 
    TabItem(imagePath: 'assets/icons/farmland.png', label: 'Commercial'), 
    TabItem(imagePath: 'assets/icons/villas.png', label: 'Independent'), 
  ]; 

  final List<GlobalKey> _tabKeys = [];
  final ScrollController _tabScrollController = ScrollController();

  double _bumpCenter = 0;
  double _bumpWidth = 0;
  double _targetCenter = 0;
  double _targetWidth = 0;
  final double bumpHorizontalPadding = 12;
  final double bumpHeight = 20;

  final Color allTabStartColor = Color(0xFF727272); 
  final Color allTabEndColor = AppColors.beeYellow; 
  final List<Color> tabColors = const [ 
    AppColors.beeYellow, 
    Color(0xFF2C3E50), 
    Color(0xFF4CAF50), 
    Color(0xFF2E7D32), 
    AppColors.beeYellow, 
    Color(0xFF9C27B0), 
    Color(0xFF607D8B), 
  ]; 

  double capsuleWidth = 60; 
  double capsuleCenterX = 60; 
  final List<Map<String, String>> _recommendedSites = [ 
    { 
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80', 
      'title': 'Aparna Apartments', 
      'sale': '20%', 
    }, 
    { 
      'image':'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80', 
      'title': 'Green Valley Towers', 
      'sale': '15%', 
    }, 
    { 
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80', 
      'title': 'Skyline Residency', 
      'sale': '10%', 
    }, 
  ]; 

  final List<Map<String, String>> _trendingApartments = [ 
    { 
      'title': 'Top Trending Apartments', 
      'image': 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80' 
    }, 
    { 
      'title': 'Luxury Villas', 
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80' 
    }, 
    { 
      'title': 'Budget Apartments', 
      'image': 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80' 
    }, 
    { 
      'title': 'Smart Homes', 
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80' 
    }, 
    { 
      'title': 'Eco Residences', 
      'image': 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80' 
    }, 
  ]; 

  final List<Map<String, String>> _popularBuilders = [ 
    {'logo': 'assets/images/sattva.png', 'discount': '30% Off'}, 
    {'logo': 'assets/images/prestige.png', 'discount': '10% Off'}, 
    {'logo': 'assets/images/lodha.png', 'discount': '15% Off'}, 
    {'logo': 'assets/images/aparna.png', 'discount': '50% Off'}, 
    {'logo': 'assets/images/home.png', 'discount': '25% Off'}, 
    {'logo': 'assets/images/my_home.png', 'discount': '40% Off'}, 
    {'logo': 'assets/images/smr.png', 'discount': '12% Off'}, 
  ]; 

  @override 
  void initState() { 
    super.initState(); 
    
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_onTabChange);

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        setState(() {
          _bumpCenter = lerpDouble(_bumpCenter, _targetCenter, _anim.value)!;
          _bumpWidth = lerpDouble(_bumpWidth, _targetWidth, _anim.value)!;
        });
      });

    for (int i = 0; i < tabs.length; i++) {
      _tabKeys.add(GlobalKey());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveBumpTo(0, animate: false);
    });
    
    _startBlinkAnimation(); 
    _scrollController.addListener(() { 
      setState(() { 
        _scrollOffset = _scrollController.offset; 
      }); 
    }); 
    _startSpecialOffersAutoPlay(); 
    _startRecommendedSitesAutoPlay();

    _simulateDataLoading();
  } 

  double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

 void _onTabChange() {
  if (_tabController.indexIsChanging ||
      _tabController.index != _tabController.previousIndex) {
    setState(() {
      selectedIndex = _tabController.index;
    });
    _moveBumpTo(_tabController.index);
    _scrollToIndex(_tabController.index);
  }
}

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctx = _tabKeys[index].currentContext;
        if (ctx == null) return;

        final renderBox = ctx.findRenderObject() as RenderBox;
        
        // Get tab center position
        final tabCenter = renderBox.localToGlobal(Offset(renderBox.size.width / 2, 0)).dx;
        final screenCenter = MediaQuery.of(context).size.width / 2;
        
        // Calculate scroll offset to center the tab
        final scrollOffset = tabCenter - screenCenter;
        final currentScroll = _tabScrollController.offset;
        double targetScroll = currentScroll + scrollOffset;

        // Clamp scroll position
        final maxScroll = _tabScrollController.position.maxScrollExtent;
        final minScroll = _tabScrollController.position.minScrollExtent;
        targetScroll = targetScroll.clamp(minScroll, maxScroll);

        if ((targetScroll - currentScroll).abs() > 1) {
          _tabScrollController.animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } catch (_) {}
    });
  }

 void _moveBumpTo(int index, {bool animate = true}) {
  try {
    final ctx = _tabKeys[index].currentContext;
    if (ctx == null) return;

    final renderBox = ctx.findRenderObject() as RenderBox;
    
    // Get tab center position relative to screen
    final tabCenter = renderBox.localToGlobal(Offset(renderBox.size.width / 2, 0)).dx;
    // Use the exact width of the tab content for perfect alignment
    final width = renderBox.size.width;

    _targetCenter = tabCenter;
    _targetWidth = width;

    if (!animate) {
      _bumpCenter = _targetCenter;
      _bumpWidth = _targetWidth;
      setState(() {});
      return;
    }

    _anim.reset();
    _anim.forward();
  } catch (_) {}
}
  void _simulateDataLoading() {
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _startSpecialOffersAutoPlay() { 
    Timer.periodic(Duration(seconds: 3), (timer) { 
      if (mounted) { 
        final nextPage = _currentSpecialOfferPage + 1; 
        if (nextPage < PropertyData.specialOffers.length) { 
          setState(() { 
            _currentSpecialOfferPage = nextPage; 
          }); 
        } else { 
          setState(() { 
            _currentSpecialOfferPage = 0; 
          }); 
        } 
      } 
    }); 
  } 

  void _startRecommendedSitesAutoPlay() { 
    Timer.periodic(Duration(seconds: 3), (timer) { 
      if (mounted && _recommendedSites.length > 1) { 
        final nextPage = (_currentRecommendedPage + 1) % _recommendedSites.length; 
        setState(() { 
          _currentRecommendedPage = nextPage; 
        }); 
      } 
    }); 
  } 

  @override 
  void dispose() { 
    _blinkTimer?.cancel(); 
    _scrollController.dispose(); 
    _tabController.dispose();
    _anim.dispose();
    _tabScrollController.dispose();
    super.dispose(); 
  } 

  void _startBlinkAnimation() { 
    _blinkTimer = Timer.periodic(Duration(milliseconds: 800), (timer) { 
      if (mounted) { 
        setState(() { 
          _isTextVisible = !_isTextVisible; 
        }); 
      } 
    }); 
  } 

  void _navigateToProfile() { 
    Navigator.push( 
      context, 
      MaterialPageRoute(builder: (context) => ProfileSettingsScreen()), 
    ); 
  } 

  void _navigateToWishlist() { 
    Navigator.push( 
      context, 
      MaterialPageRoute(builder: (context) => WishlistScreen()), 
    ); 
  } 

  void _navigateToNotifications() { 
    Navigator.push( 
      context, 
      MaterialPageRoute(builder: (context) => NotificationsScreen()), 
    ); 
  } 

  String get _searchHintText { 
    switch (selectedIndex) { 
      case 0: return 'Search "Properties"'; 
      case 1: return 'Search "Apartments"'; 
      case 2: return 'Search "Villas"'; 
      case 3: return 'Search "Farmlands"'; 
      case 4: return 'Search "Open Plots"'; 
      case 5: return 'Search "Commercial"'; 
      case 6: return 'Search "Independent Houses"'; 
      default: return 'Search "Properties"'; 
    } 
  } 

  Widget _buildSearchBar() { 
    final isSmallScreen = MediaQuery.of(context).size.width < 360; 
    
    if (_isLoading) {
      return _buildSearchBarShimmer(isSmallScreen);
    }
    
    return Padding( 
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16), 
      child: Row( 
        children: [ 
          Expanded( 
            child: Container( 
              height: isSmallScreen ? 36 : 40, 
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 14), 
              decoration: BoxDecoration( 
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8), 
                boxShadow: [ 
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)) 
                ], 
              ), 
              child: Row( 
                children: [ 
                  Icon(Icons.search, color: Color(0xFFB0BEC5), size: isSmallScreen ? 18 : 20), 
                  SizedBox(width: isSmallScreen ? 6 : 10), 
                  Expanded( 
                    child: TextField( 
                      decoration: InputDecoration( 
                        border: InputBorder.none, 
                        hintText: _searchHintText, 
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: isSmallScreen ? 13 : 14), 
                      ), 
                    ), 
                  ), 
                  Icon(Icons.mic, color: Colors.grey, size: isSmallScreen ? 18 : 20), 
                ], 
              ), 
            ), 
          ), 
          SizedBox(width: isSmallScreen ? 8 : 12), 
          GestureDetector( 
            onTap: _navigateToWishlist, 
            child: Container( 
              width: isSmallScreen ? 28 : 34, 
              height: isSmallScreen ? 28 : 34, 
              decoration: BoxDecoration( 
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8), 
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))], 
              ), 
              child: Icon(Icons.favorite_border, color: AppColors.beeYellow, size: isSmallScreen ? 20 : 24), 
            ), 
          ), 
        ], 
      ), 
    ); 
  }

  Widget _buildSearchBarShimmer(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: isSmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: isSmallScreen ? 28 : 34,
              height: isSmallScreen ? 28 : 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Color(0xFFE8ECFC), 
      body: Stack( 
        children: [ 
          _buildBody(), 
          if (bottomNavIndex == 0) Positioned( 
            bottom: 10, 
            left: 0, 
            right: 0, 
            child: Center( 
              child: StickyMapButton(), 
            ), 
          ), 
        ], 
      ), 
      bottomNavigationBar: CustomBottomBar( 
        currentIndex: bottomNavIndex, 
        onTabSelected: (i) { 
          setState(() { 
            bottomNavIndex = i; 
          }); 
        }, 
      ), 
    ); 
  } 

  Widget _buildBody() { 
    final screenWidth = MediaQuery.of(context).size.width; 
    final screenHeight = MediaQuery.of(context).size.height; 
    final isSmallScreen = screenWidth < 360; 
    double waveOpacity = 1.0 - (_scrollOffset / 100).clamp(0.0, 1.0); 
    bool shouldUseWhiteIcons = waveOpacity > 0.5; 

    if (bottomNavIndex == 3) { 
      return premium_screen.PremiumPlanScreen(); 
    } 
    if (bottomNavIndex == 2) { 
      return ai.AiAssistantScreen(); 
    } 
    if (bottomNavIndex == 1) { 
      return EmiCalculatorScreen(); 
    } 

    return Stack( 
      children: [ 
        if (waveOpacity > 0) Positioned( 
          top: -_scrollOffset.clamp(0.0, screenHeight * 0.40), 
          left: 0, 
          right: 0, 
          child: Opacity( 
            opacity: waveOpacity, 
            child: SizedBox( 
              height: screenHeight * 0.58, 
              child: CustomPaint( 
                size: Size(screenWidth, screenHeight * 0.40), 
                painter: TopGradientWavePainter( 
                  selectedIndex == 0 ? null : tabColors[selectedIndex], 
                  startColor: selectedIndex == 0 ? allTabStartColor : null, 
                  endColor: selectedIndex == 0 ? allTabEndColor : null, 
                ), 
              ), 
            ), 
          ), 
        ), 
        SafeArea( 
          child: Column( 
            children: [ 
              const SizedBox(height: 12), 
              _isLoading 
                  ? _buildTopAppBarShimmer(isSmallScreen)
                  : TopAppBar( 
                      shouldUseWhiteIcons: shouldUseWhiteIcons, 
                      isSmallScreen: isSmallScreen, 
                      onProfileTap: _navigateToProfile, 
                      onWishlistTap: _navigateToWishlist, 
                      onNotificationsTap: _navigateToNotifications, 
                    ), 
              const SizedBox(height: 12), 
              _buildSearchBar(), 
              const SizedBox(height: 12), 
              _buildNewTabBar(shouldUseWhiteIcons, isSmallScreen),
              Expanded( 
                child: _buildScrollableContent(), 
              ), 
            ], 
          ), 
        ), 
      ], 
    ); 
  }

  Widget _buildNewTabBar(bool shouldUseWhiteIcons, bool isSmallScreen) {
   
  return SizedBox(
    height: isSmallScreen ? 70 : 84,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              height: isSmallScreen ? 70 : 84,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(tabs.length, (i) {
                  final Color selectedColor = i == 0 ? allTabEndColor : tabColors[i];
                  final Color unselectedColor = selectedIndex == 0 ? 
                    (shouldUseWhiteIcons ? Colors.white : Colors.black) : Colors.black;
                  final bool isSelected = _tabController.index == i;
                  
                  return GestureDetector(
                    onTap: () {
                      _tabController.animateTo(i);
                    },
                    child: Container(
                      key: _tabKeys[i],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          tabs[i].imagePath != null
                              ? Image.asset(
                                  tabs[i].imagePath!,
                                  height: isSmallScreen ? 20 : 24,
                                  width: isSmallScreen ? 20 : 24,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                )
                              : Icon(
                                  tabs[i].icon!,
                                  size: isSmallScreen ? 20 : 24,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? selectedColor
                                  : unselectedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        // Capsule bump
        Positioned(
          top: isSmallScreen ? 48 : 48,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: CapsuleWaveLinePainter(
              centerX: _bumpCenter,
              capsuleWidth: _bumpWidth,
              capsuleHeight: bumpHeight,
              borderRadius: 12,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: bumpHeight + 8,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTopAppBarShimmer(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildScrollableContent() { 
  if (_isLoading) {
    return _buildRealisticContentShimmer();
  }
  
  return SingleChildScrollView( 
    controller: _scrollController, 
    physics: const BouncingScrollPhysics(), 
    child: Column( 
      children: [ 
        // Use Container with zero constraints
        Container(
          width: 400,
         
          margin: EdgeInsets.fromLTRB(12, 2, 6, 2),
          child: SpecialOffersSection( 
            dotsKey: GlobalKey(),
            currentSpecialOfferPage: _currentSpecialOfferPage, 
            onPageChanged: (index) { 
              setState(() { 
                _currentSpecialOfferPage = index; 
              }); 
            }, 
          ),
        ),
        const SizedBox(height: 20), 
        if (selectedIndex == 0) 
          _buildAllTabContent()
        else 
          OtherTabsContent( 
            selectedBuilderIndex: selectedBuilderIndex, 
            currentRecommendedPage: _currentRecommendedPage, 
            recommendedSites: _recommendedSites, 
            trendingApartments: _trendingApartments, 
            popularBuilders: _popularBuilders, 
            onBuilderCardTap: (index) { 
              setState(() { 
                selectedBuilderIndex = index; 
              }); 
            }, 
            onRecommendedPageChanged: (index) { 
              setState(() { 
                _currentRecommendedPage = index; 
              }); 
            }, 
          ), 
        const SizedBox(height: 20), 
      ], 
    ), 
  ); 
}

  Widget _buildAllTabContent() {
    return Column(
      children: [
        _buildFilterChipsSection(),
        PropertyDeckSection(),
        MustVisitSection(trendingApartments: _trendingApartments),
        const SizedBox(height: 20), 
        const FeaturedSitesSection(),
      ],
    );
  }

  Widget _buildFilterChipsSection() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isSmallScreen ? 48 : 52,
                    height: isSmallScreen ? 48 : 52,
                    child: Image.asset(
                      'assets/icons/design.png',
                      fit: BoxFit.contain,
                      color: AppColors.beeYellow,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.architecture,
                        color: AppColors.beeYellow,
                        size: isSmallScreen ? 42 : 46,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 14),
                  Text(
                    'Popular Around you',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 14),
                  SizedBox(
                    width: isSmallScreen ? 48 : 52,
                    height: isSmallScreen ? 48 : 52,
                    child: Image.asset(
                      'assets/icons/design.png',
                      fit: BoxFit.contain,
                      color: AppColors.beeYellow,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.construction,
                        color: AppColors.beeYellow,
                        size: isSmallScreen ? 42 : 46,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(Icons.filter_list_alt, 'Filter ▼'),
                const SizedBox(width: 8),
                _buildFilterChip(Icons.percent_rounded, 'Offers', color: Colors.redAccent),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Near & Top Rated'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Rating 4.5+'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Ready to Move'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Newly Launched'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: color == Colors.black ? Colors.black87 : color),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color == Colors.black ? Colors.black87 : color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticContentShimmer() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Force remove all padding in shimmer version too
          Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: _buildRealisticSpecialOffersShimmer(),
          ),
          const SizedBox(height: 20),
          _buildRealisticPropertyListShimmer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRealisticSpecialOffersShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRealisticPropertyListShimmer() {
    return Column(
      children: [
        _buildPropertyCardShimmer(),
        const SizedBox(height: 12),
        _buildPropertyCardShimmer(),
        const SizedBox(height: 12),
        _buildPropertyCardShimmer(),
        const SizedBox(height: 20),
        _buildBuildersShimmer(),
        const SizedBox(height: 20),
        _buildFilterSectionShimmer(),
        const SizedBox(height: 20),
        _buildFeaturedSitesShimmer(),
      ],
    );
  }

  Widget _buildPropertyCardShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuildersShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSectionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Container(
              width: 100,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSitesShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopGradientWavePainter extends CustomPainter {
  final Color? color;
  final Color? startColor;
  final Color? endColor;
  TopGradientWavePainter(this.color, {this.startColor, this.endColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: startColor != null && endColor != null
          ? [startColor!, endColor!]
          // ignore: deprecated_member_use
          : [Color(0xFFE8ECFC), color!.withOpacity(0.8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, 0);
    final double baseline = 28.0;
    final double crest = 46.0;
    final double trough = 12.0;

    path.lineTo(0, size.height - baseline);

    final double waveWidth = size.width / 3;
    path.quadraticBezierTo(waveWidth * 0.25, size.height - crest, waveWidth, size.height - baseline);
    path.quadraticBezierTo(waveWidth * 1.5, size.height - trough, waveWidth * 2, size.height - baseline);
    path.quadraticBezierTo(waveWidth * 2.75, size.height - crest, size.width, size.height - baseline);

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TopGradientWavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.startColor != startColor || oldDelegate.endColor != endColor;
}