import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/bottom_bar_screens/ai.dart' as ai;
import 'package:real_beez/screens/bottom_bar_screens/emi_calculator.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/premium_screens/premium_plan.dart'
    as premium_screen;
import 'package:real_beez/screens/profile_screens/profile.dart';
import 'package:real_beez/screens/cutsom_widgets/custom_bottom_bar.dart';
import 'package:real_beez/screens/cutsom_widgets/swipe_cards.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:real_beez/screens/header/wishlist_screen.dart';
import 'package:real_beez/screens/header/notification_screen.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final int price;
  final String currency;
  final String status;
  final Address address;
  final List<PropertyImage> images;
  final List<String> features;
  final List<String> amenities;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.status,
    required this.address,
    required this.images,
    required this.features,
    required this.amenities,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Address {
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;

  Address({
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });
}

class PropertyImage {
  final String url;
  final bool isPrimary;

  PropertyImage({required this.url, required this.isPrimary});
}

class WishlistManager {
  static final WishlistManager _instance = WishlistManager._internal();
  factory WishlistManager() => _instance;
  WishlistManager._internal();

  final List<Property> _wishlist = [];

  void addToWishlist(Property property) {
    if (!_wishlist.contains(property)) {
      _wishlist.add(property);
    }
  }

  void removeFromWishlist(Property property) {
    _wishlist.remove(property);
  }

  bool isInWishlist(Property property) {
    return _wishlist.contains(property);
  }

  List<Property> getWishlist() => _wishlist;
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int bottomNavIndex = 0;

  int selectedCategoryIndex = 0;
  int selectedBuilderIndex = 0;

  bool _isTextVisible = true;
  Timer? _blinkTimer;

  // Add scroll controllers for carousel animations
  final ScrollController _firstRowScrollController = ScrollController();
  final ScrollController _secondRowScrollController = ScrollController();
  Timer? _firstRowTimer;
  Timer? _secondRowTimer;

  // Add touch interaction variables
  bool _isFirstRowDragging = false;
  bool _isSecondRowDragging = false;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  final List<TabItem> tabs = [
    TabItem(imagePath: 'assets/icons/all.png', label: 'All'),
    TabItem(imagePath: 'assets/icons/apartment.png', label: 'Apartment'),
    TabItem(imagePath: 'assets/icons/villas.png', label: 'Villas'),
    TabItem(imagePath: 'assets/icons/farmland.png', label: 'Farmlands'),
    TabItem(imagePath: 'assets/icons/open_plots.png', label: 'Open Plots'),
  ];

  final Color allTabStartColor = Color(0xFF727272);
  final Color allTabEndColor = Color(0xFFD79A2F);
  final List<Color> tabColors = const [
    Color(0xFFD79A2F),
    Color(0xFF2C3E50),
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
    Color(0xFFD79A2F),
  ];

  final List<GlobalKey> _tabKeys = [];
  double capsuleWidth = 60;
  double capsuleCenterX = 60;

  final PageController _pageController = PageController(
    viewportFraction: 0.9,
    initialPage: 0,
  );

  final List<Map<String, String>> specialOffers = [
    {'title': 'My Home Avatar', 'image': 'assets/images/unlock1.png'},
    {'title': 'Ankura Villas', 'image': 'assets/images/unlock2.png'},
    {'title': 'Prestige City', 'image': 'assets/images/unlock1.png'},
    {'title': 'Jumbooo City', 'image': 'assets/images/unlock2.png'},
  ];

  // Add more builder images for better carousel effect
  final List<String> builderImages = [
    'assets/images/provincia.png',
    'assets/images/sattva.png',
    'assets/images/prestige.png',
    'assets/images/lodha.png',
    'assets/images/aparna.png',
    'assets/images/my_home.png',
    'assets/images/home.png',
    'assets/images/smr.png',
    'assets/images/provincia.png', // Duplicate for continuous effect
    'assets/images/sattva.png',
    'assets/images/prestige.png',
    'assets/images/lodha.png',
  ];

  final List<Map<String, dynamic>> propertyListings = [
    {
      'title': '2BHK Apartments',
      'subtitle': 'Ankura Apartments',
      'location': 'Gachibowli',
      'price': 'Price Range start from',
      'priceRange': '80 Lakhs - 1 Cr',
      'image': 'assets/images/property1.png',
      'isNew': true,
      'property': Property(
        id: '1',
        title: 'Ankura Apartments',
        description: '2BHK Apartments in Gachibowli',
        price: 8000000,
        currency: 'INR',
        status: 'pre_launch',
        address: Address(
          street: 'Gachibowli',
          area: 'Gachibowli',
          city: 'Hyderabad',
          state: 'Telangana',
          pincode: '500032',
        ),
        images: [
          PropertyImage(url: 'assets/images/property1.png', isPrimary: true),
        ],
        features: [],
        amenities: [],
      ),
    },
    {
      'title': '3BHK Apartments',
      'subtitle': 'Prestige Apartments',
      'location': 'Hitech City',
      'price': 'Price Range start from',
      'priceRange': '1.2Cr - 1.5Cr',
      'image': 'assets/images/property2.png',
      'isNew': false,
      'property': Property(
        id: '2',
        title: 'Prestige Apartments',
        description: '3BHK Apartments in Hitech City',
        price: 12000000,
        currency: 'INR',
        status: 'ready_to_move',
        address: Address(
          street: 'Hitech City',
          area: 'Hitech City',
          city: 'Hyderabad',
          state: 'Telangana',
          pincode: '500081',
        ),
        images: [
          PropertyImage(url: 'assets/images/property2.png', isPrimary: true),
        ],
        features: [],
        amenities: [],
      ),
    },
    {
      'title': '4BHK Villas',
      'subtitle': 'Luxury Villas',
      'location': 'Jubilee Hills',
      'price': 'Price Range start from',
      'priceRange': '2.5Cr - 3Cr',
      'image': 'assets/images/property3.png',
      'isNew': true,
      'property': Property(
        id: '3',
        title: 'Luxury Villas',
        description: '4BHK Villas in Jubilee Hills',
        price: 25000000,
        currency: 'INR',
        status: 'pre_launch',
        address: Address(
          street: 'Jubilee Hills',
          area: 'Jubilee Hills',
          city: 'Hyderabad',
          state: 'Telangana',
          pincode: '500033',
        ),
        images: [
          PropertyImage(url: 'assets/images/property3.png', isPrimary: true),
        ],
        features: [],
        amenities: [],
      ),
    },
  ];

  @override
  void initState() {
    super.initState();

    _tabKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCapsulePosition();
    });

    // Start blink animation
    _startBlinkAnimation();

    // Add scroll listener
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Start carousel animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCarouselAnimations();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _firstRowTimer?.cancel();
    _secondRowTimer?.cancel();
    _scrollController.dispose();
    _firstRowScrollController.dispose();
    _secondRowScrollController.dispose();
    super.dispose();
  }

  void _startCarouselAnimations() {
    // First row scrolls to the right
    _firstRowTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (_firstRowScrollController.hasClients && !_isFirstRowDragging) {
        final maxScroll = _firstRowScrollController.position.maxScrollExtent;
        final currentScroll = _firstRowScrollController.offset;

        if (currentScroll >= maxScroll) {
          _firstRowScrollController.jumpTo(0);
        } else {
          _firstRowScrollController.animateTo(
            currentScroll + 0.8,
            duration: Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });

    // Second row scrolls to the left
    _secondRowTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (_secondRowScrollController.hasClients && !_isSecondRowDragging) {
        final maxScroll = _secondRowScrollController.position.maxScrollExtent;
        final currentScroll = _secondRowScrollController.offset;

        if (currentScroll <= 0) {
          _secondRowScrollController.jumpTo(maxScroll);
        } else {
          _secondRowScrollController.animateTo(
            currentScroll - 0.8,
            duration: Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
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

  Widget _buildBlinkingText() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: _isTextVisible ? 1.0 : 0.3,
      child: Text(
        'First 100 People 10% Sale',
        style: TextStyle(
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.width < 360 ? 14 : 15,
          fontWeight: FontWeight.w700,
          height: 0.5,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  void _updateCapsulePosition() {
    final key = _tabKeys[selectedIndex];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      setState(() {
        capsuleWidth = size.width + 40;
        capsuleCenterX = offset.dx + size.width / 2;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8ECFC),
      body: Stack(
        children: [
          _buildBody(),
          if (bottomNavIndex == 0)
            Positioned(
              bottom: kBottomNavigationBarHeight + 16,
              right: 16,
              child: _buildMapButton(),
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

  Widget _buildMapButton() {
    return Container(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            print('Map button tapped');
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    if (bottomNavIndex == 3) {
      return premium_screen.PremiumPlanScreen();
    }
    if (bottomNavIndex == 2) {
      return ai.AiAssistantScreen();
    }
    if (bottomNavIndex == 1) {
      // Replace enquiry screen with EMI calculator
      return EmiCalculatorScreen();
    }

    bool showWave = _scrollOffset < 100;

    return Stack(
      children: [
        if (showWave)
          Positioned(
            top: -_scrollOffset.clamp(
              0.0,
              screenHeight * 0.60,
            ), // Moves up with scroll
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.60,
              child: CustomPaint(
                size: Size(screenWidth, screenHeight * 0.60),
                painter: TopGradientWavePainter(
                  selectedIndex == 0 ? null : tabColors[selectedIndex],
                  startColor: selectedIndex == 0 ? allTabStartColor : null,
                  endColor: selectedIndex == 0 ? allTabEndColor : null,
                ),
              ),
            ),
          ),

        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Top Bar - Fixed
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: showWave ? Colors.white : Colors.black,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 6),
                        Text(
                          "Hyderabad, TG",
                          style: TextStyle(
                            color: showWave ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: showWave ? Colors.white : Colors.black,
                          size: isSmallScreen ? 18 : 20,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToNotifications,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: showWave ? Colors.white : Colors.black,
                                size: isSmallScreen ? 22 : 28,
                              ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: CircleAvatar(
                            radius: isSmallScreen ? 14 : 18,
                            backgroundImage: AssetImage(
                              "assets/images/submit.png",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search Bar - Fixed
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: isSmallScreen ? 36 : 40,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Color(0xFFB0BEC5),
                              size: isSmallScreen ? 18 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search "Apartments"',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.mic,
                              color: Colors.grey,
                              size: isSmallScreen ? 18 : 20,
                            ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.beeYellow,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Stack(
                children: [
                  SizedBox(
                    height: isSmallScreen ? 70 : 84,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(tabs.length, (index) {
                        final isSelected = selectedIndex == index;
                        final Color selectedColor = index == 0
                            ? allTabEndColor
                            : tabColors[index];
                        final Color unselectedColor = selectedIndex == 0
                            ? (showWave ? Colors.white : Colors.black)
                            : Colors.black;
                        return GestureDetector(
                          key: _tabKeys[index],
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _updateCapsulePosition();
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(height: 6),
                              tabs[index].imagePath != null
                                  ? Image.asset(
                                      tabs[index].imagePath!,
                                      height: isSmallScreen ? 20 : 24,
                                      width: isSmallScreen ? 20 : 24,
                                      color: isSelected
                                          ? selectedColor
                                          : unselectedColor,
                                    )
                                  : Icon(
                                      tabs[index].icon!,
                                      color: isSelected
                                          ? selectedColor
                                          : unselectedColor,
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                              SizedBox(height: 4),
                              Text(
                                tabs[index].label,
                                style: TextStyle(
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
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
                        centerX: capsuleCenterX,
                        capsuleWidth: capsuleWidth,
                        capsuleHeight: 30,
                        borderRadius: 10,
                      ),
                    ),
                  ),
                ],
              ),

              // Scrollable content area
              Expanded(child: _buildScrollableContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Special offers carousel
          SizedBox(
            height: isSmallScreen ? 170 : 190,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isSmallScreen ? 8.0 : 12.0),
                  child: Container(
                    width: isSmallScreen ? 60 : 80,
                    height: isSmallScreen ? 60 : 80,
                    margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/images/special_offers.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: specialOffers.length,
                    padEnds: false,
                    itemBuilder: (context, index) {
                      final offer = specialOffers[index];
                      return _buildOfferCard(
                        imageUrl: offer['image']!,
                        title: offer['title']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: specialOffers.length,
              effect: WormEffect(
                dotColor: Colors.white54,
                activeDotColor: Colors.white,
                dotHeight: 6,
                dotWidth: 6,
              ),
            ),
          ),
          SizedBox(height: 30),
          // Content based on selected tab
          if (selectedIndex == 0) ...[
            // ALL TAB: Show swipe cards only - KEEPING THE ORIGINAL
            PropertyDeckSection(), // This should be your original swipe cards widget
          ] else ...[
            // OTHER TABS: Show Popular Builders section first
            _buildPopularBuildersSection(),
            SizedBox(height: 24),
            _buildPromotionalBanner(),
            SizedBox(height: 16),
            // Then show Featured Sites section
            _buildFeaturedSitesSection(),
          ],
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Popular Builders Section with Carousel Animation and Touch Interaction
  Widget _buildPopularBuildersSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered header with larger decorative icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left decorative icon - Extra large size
              Container(
                width: isSmallScreen ? 48 : 52,
                height: isSmallScreen ? 48 : 52,
                child: Image.asset(
                  'assets/icons/design.png',
                  fit: BoxFit.contain,
                  color: Color(0xFFD79A2F),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.architecture,
                    color: Color(0xFFD79A2F),
                    size: isSmallScreen ? 42 : 46,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),

              // Text only
              Text(
                'Some Popular Builders',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),

              // Right decorative icon - Extra large size
              Container(
                width: isSmallScreen ? 48 : 52,
                height: isSmallScreen ? 48 : 52,
                child: Image.asset(
                  'assets/icons/design.png',
                  fit: BoxFit.contain,
                  color: Color(0xFFD79A2F),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.construction,
                    color: Color(0xFFD79A2F),
                    size: isSmallScreen ? 42 : 46,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // First Row - Scrolls to the Right with Touch Interaction
          Container(
            height: isSmallScreen ? 100 : 110,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  setState(() {
                    _isFirstRowDragging = true;
                  });
                } else if (scrollNotification is ScrollEndNotification) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (mounted) {
                      setState(() {
                        _isFirstRowDragging = false;
                      });
                    }
                  });
                }
                return false;
              },
              child: ListView.builder(
                controller: _firstRowScrollController,
                scrollDirection: Axis.horizontal,
                physics:
                    BouncingScrollPhysics(), // Enable manual scrolling with bounce effect
                itemCount: builderImages.length,
                itemBuilder: (context, index) {
                  return _buildBuilderCard(index);
                },
              ),
            ),
          ),

          SizedBox(height: 12),

          // Second Row - Scrolls to the Left with Touch Interaction
          Container(
            height: isSmallScreen ? 100 : 110,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  setState(() {
                    _isSecondRowDragging = true;
                  });
                } else if (scrollNotification is ScrollEndNotification) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (mounted) {
                      setState(() {
                        _isSecondRowDragging = false;
                      });
                    }
                  });
                }
                return false;
              },
              child: ListView.builder(
                controller: _secondRowScrollController,
                scrollDirection: Axis.horizontal,
                physics:
                    BouncingScrollPhysics(), // Enable manual scrolling with bounce effect
                itemCount: builderImages.length,
                itemBuilder: (context, index) {
                  return _buildBuilderCard(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 4,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Selected builder logo
          Container(
            width: isSmallScreen ? 32 : 36,
            height: isSmallScreen ? 32 : 36,
            child: selectedBuilderIndex < builderImages.length
                ? Image.asset(
                    builderImages[selectedBuilderIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.business,
                        color: Color(0xFFD79A2F),
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.business,
                      color: Color(0xFFD79A2F),
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 10),

          // Text content with blink animation
          Expanded(
            child: Container(
              height: isSmallScreen ? 12 : 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildBlinkingText()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builder card with yellow background on selection
  Widget _buildBuilderCard(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isSelected = selectedBuilderIndex == index;

    return GestureDetector(
      onTap: () => _onBuilderCardTap(index),
      child: Container(
        width: isSmallScreen ? 90 : 100,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD79A2F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Image.asset(
              builderImages[index],
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              fit: BoxFit.contain,
              color: isSelected ? Colors.white : null,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business,
                color: isSelected ? Colors.white : Colors.grey,
                size: isSmallScreen ? 30 : 35,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builder card tap handler
  void _onBuilderCardTap(int index) {
    setState(() {
      selectedBuilderIndex = index;
    });
  }

  // Featured Sites Section - ORIGINAL CODE
  Widget _buildFeaturedSitesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    List<Map<String, dynamic>> categoryData;
    List<String> categoryTitles;

    if (selectedIndex == 1) {
      categoryTitles = [
        '2 BHK Apartments',
        '3 BHK Apartments',
        '4 BHK Apartments',
      ];
      categoryData = [
        {
          'items': [
            {
              'subtitle': 'Ankura Apartments',
              'location': 'Gachibowli',
              'price': 'Price Range start from',
              'priceRange': '80 Lakhs - 1 Cr',
              'image': 'assets/images/villa3.png',
              'isNew': true,
              'property': Property(
                id: '4',
                title: 'Ankura Apartments',
                description: '2BHK Apartments in Gachibowli',
                price: 8000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Gachibowli',
                  area: 'Gachibowli',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500032',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Prestige Residences',
              'location': 'Hitech City',
              'price': 'Price Range start from',
              'priceRange': '85 Lakhs - 1.1 Cr',
              'image': 'assets/images/villa3.png',
              'isNew': false,
              'property': Property(
                id: '5',
                title: 'Prestige Residences',
                description: '2BHK Apartments in Hitech City',
                price: 8500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hitech City',
                  area: 'Hitech City',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Nova Homes',
              'location': 'Kondapur',
              'price': 'Price Range start from',
              'priceRange': '75 Lakhs - 95 Lakhs',
              'image': 'assets/images/villa3.png',
              'isNew': false,
              'property': Property(
                id: '6',
                title: 'Nova Homes',
                description: '2BHK Apartments in Kondapur',
                price: 7500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Kondapur',
                  area: 'Kondapur',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500084',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Prestige Apartments',
              'location': 'Hitech City',
              'price': 'Price Range start from',
              'priceRange': '1.2Cr - 1.5Cr',
              'image': 'assets/images/apartment1.png',
              'isNew': false,
              'property': Property(
                id: '7',
                title: 'Prestige Apartments',
                description: '3BHK Apartments in Hitech City',
                price: 12000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hitech City',
                  area: 'Hitech City',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Regal Residency',
              'location': 'Madhapur',
              'price': 'Price Range start from',
              'priceRange': '1.1Cr - 1.4Cr',
              'image': 'assets/images/apartment1.png',
              'isNew': true,
              'property': Property(
                id: '8',
                title: 'Regal Residency',
                description: '3BHK Apartments in Madhapur',
                price: 11000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Madhapur',
                  area: 'Madhapur',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Luxury Towers',
              'location': 'Jubilee Hills',
              'price': 'Price Range start from',
              'priceRange': '2.5Cr - 3Cr',
              'image': 'assets/images/apartment2.png',
              'isNew': true,
              'property': Property(
                id: '9',
                title: 'Luxury Towers',
                description: '4BHK Apartments in Jubilee Hills',
                price: 25000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Jubilee Hills',
                  area: 'Jubilee Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500033',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Skyline Villas',
              'location': 'Banjara Hills',
              'price': 'Price Range start from',
              'priceRange': '3.2Cr - 3.8Cr',
              'image': 'assets/images/apartment2.png',
              'isNew': false,
              'property': Property(
                id: '10',
                title: 'Skyline Villas',
                description: '4BHK Apartments in Banjara Hills',
                price: 32000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Banjara Hills',
                  area: 'Banjara Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500034',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
      ];
    } else if (selectedIndex == 2) {
      // Villas: 2BHK, 3BHK, 4BHK
      categoryTitles = ['2 BHK Villas', '3 BHK Villas', '4 BHK Villas'];
      categoryData = [
        {
          'items': [
            {
              'subtitle': 'Green Villa',
              'location': 'Shamirpet',
              'price': 'Price Range start from',
              'priceRange': '1.8Cr - 2Cr',
              'image': 'assets/images/villa1.png',
              'isNew': true,
              'property': Property(
                id: '11',
                title: 'Green Villa',
                description: '2BHK Villas in Shamirpet',
                price: 18000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Shamirpet',
                  area: 'Shamirpet',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500078',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Palm Villas',
              'location': 'Nagole',
              'price': 'Price Range start from',
              'priceRange': '1.5Cr - 1.8Cr',
              'image': 'assets/images/villa1.png',
              'isNew': false,
              'property': Property(
                id: '12',
                title: 'Palm Villas',
                description: '2BHK Villas in Nagole',
                price: 15000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Nagole',
                  area: 'Nagole',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500068',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Lake View Villas',
              'location': 'Gachibowli',
              'price': 'Price Range start from',
              'priceRange': '2.5Cr - 3Cr',
              'image': 'assets/images/villa2.png',
              'isNew': false,
              'property': Property(
                id: '13',
                title: 'Lake View Villas',
                description: '3BHK Villas in Gachibowli',
                price: 25000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Gachibowli',
                  area: 'Gachibowli',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500032',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Royal Greens',
              'location': 'Kukatpally',
              'price': 'Price Range start from',
              'priceRange': '2.2Cr - 2.6Cr',
              'image': 'assets/images/villa2.png',
              'isNew': true,
              'property': Property(
                id: '14',
                title: 'Royal Greens',
                description: '3BHK Villas in Kukatpally',
                price: 22000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Kukatpally',
                  area: 'Kukatpally',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500072',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Heritage Villa',
              'location': 'Jubilee Hills',
              'price': 'Price Range start from',
              'priceRange': '4Cr - 5Cr',
              'image': 'assets/images/villa3.png',
              'isNew': true,
              'property': Property(
                id: '15',
                title: 'Heritage Villa',
                description: '4BHK Villas in Jubilee Hills',
                price: 40000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Jubilee Hills',
                  area: 'Jubilee Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500033',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
      ];
    } else if (selectedIndex == 3) {
      // Farmlands: sample subcategories
      categoryTitles = [
        'Small Farmlands',
        'Medium Farmlands',
        'Large Farmlands',
      ];
      categoryData = [
        {
          'items': [
            {
              'subtitle': 'Sunrise Farms',
              'location': 'Outskirts',
              'price': 'Price Range start from',
              'priceRange': '30 Lakhs - 50 Lakhs',
              'image': 'assets/images/farmland1.png',
              'isNew': false,
              'property': Property(
                id: '16',
                title: 'Sunrise Farms',
                description: 'Small Farmland in Outskirts',
                price: 3000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Outskirts',
                  area: 'Outskirts',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500075',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
            {
              'subtitle': 'Green Acres',
              'location': 'Countryside',
              'price': 'Price Range start from',
              'priceRange': '35 Lakhs - 55 Lakhs',
              'image': 'assets/images/farmland1.png',
              'isNew': true,
              'property': Property(
                id: '17',
                title: 'Green Acres',
                description: 'Small Farmland in Countryside',
                price: 3500000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Countryside',
                  area: 'Countryside',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500076',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Harvest Fields',
              'location': 'Periphery',
              'price': 'Price Range start from',
              'priceRange': '60 Lakhs - 90 Lakhs',
              'image': 'assets/images/farmland2.png',
              'isNew': false,
              'property': Property(
                id: '18',
                title: 'Harvest Fields',
                description: 'Medium Farmland in Periphery',
                price: 6000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Periphery',
                  area: 'Periphery',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500077',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Valley Farms',
              'location': 'Outer Ring',
              'price': 'Price Range start from',
              'priceRange': '1Cr - 1.5Cr',
              'image': 'assets/images/farmland1.png',
              'isNew': true,
              'property': Property(
                id: '19',
                title: 'Valley Farms',
                description: 'Large Farmland in Outer Ring',
                price: 10000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Outer Ring',
                  area: 'Outer Ring',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500079',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
      ];
    } else {
      // Open Plots (selectedIndex == 4 or fallback)
      categoryTitles = ['Small Plots', 'Medium Plots', 'Large Plots'];
      categoryData = [
        {
          'items': [
            {
              'subtitle': 'Emerald Plots',
              'location': 'Town Edge',
              'price': 'Price Range start from',
              'priceRange': '25 Lakhs - 35 Lakhs',
              'image': 'assets/images/openplot1.png',
              'isNew': false,
              'property': Property(
                id: '20',
                title: 'Emerald Plots',
                description: 'Small Plots in Town Edge',
                price: 2500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Town Edge',
                  area: 'Town Edge',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500080',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Sunset Plots',
              'location': 'Near Lake',
              'price': 'Price Range start from',
              'priceRange': '45 Lakhs - 60 Lakhs',
              'image': 'assets/images/openplot2.png',
              'isNew': true,
              'property': Property(
                id: '21',
                title: 'Sunset Plots',
                description: 'Medium Plots Near Lake',
                price: 4500000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Near Lake',
                  area: 'Near Lake',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500082',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Hilltop Plots',
              'location': 'Hill Area',
              'price': 'Price Range start from',
              'priceRange': '75 Lakhs - 95 Lakhs',
              'image': 'assets/images/openplot1.png',
              'isNew': false,
              'property': Property(
                id: '22',
                title: 'Hilltop Plots',
                description: 'Large Plots in Hill Area',
                price: 7500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hill Area',
                  area: 'Hill Area',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500083',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
            },
          ],
        },
      ];
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title (main)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Sites',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: isSmallScreen ? 16 : 18,
                        color: Color(0xFFD79A2F),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),

            Column(
              children: categoryData.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final section = entry.value;
                final List items = section['items'] as List;
                final categoryTitle = categoryTitles[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        categoryTitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.beeYellow,
                        ),
                      ),
                    ),

                    // Horizontal carousel
                    SizedBox(
                      height: isSmallScreen ? 280 : 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, idx) {
                          final property = items[idx] as Map<String, dynamic>;
                          return _buildPropertyCard(
                            property: property,
                            index: idx,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard({
    required Map<String, dynamic> property,
    required int index,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: () {
        // Navigate to PropertyDetailsScreen when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailScreen()),
        );
      },
      child: Container(
        width: isSmallScreen ? 280 : 290,
        height: isSmallScreen ? 120 : 130,
        margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16, bottom: 110),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top content area (property details)
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property['subtitle'] ?? '',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // Location icon
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: isSmallScreen ? 14 : 16,
                                color: Color(0xFFD79A2F),
                              ),
                            ),
                            SizedBox(width: 6),
                            // Wishlist icon
                            _AnimatedWishlistButton(
                              property: property['property'],
                            ),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isSmallScreen ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property['location'] ?? '',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Text(
                      property['price'] ?? '',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.black54,
                      ),
                    ),

                    Text(
                      property['priceRange'] ?? '',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image area
            Container(
              height: isSmallScreen ? 80 : 90,
              width: double.infinity,
              child: Stack(
                children: [
                  // Image that completely touches the card container edges
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: property['image'] != null
                          ? Image.asset(
                              property['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),

                  if (property['isNew'] == true)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 2),
                            Text(
                              "New",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard({required String imageUrl, required String title}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.only(left: 2, right: isSmallScreen ? 16 : 24),
      constraints: BoxConstraints(maxHeight: isSmallScreen ? 150 : 170),
      width: isSmallScreen
          ? screenWidth * 0.20
          : isMediumScreen
          ? screenWidth * 0.17
          : screenWidth * 0.14,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.startsWith('assets/')
                ? Image.asset(
                    imageUrl,
                    height: isSmallScreen ? 74 : 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl,
                    height: isSmallScreen ? 74 : 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "More Details:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD79A2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 4 : 6,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: Text(
                      "Unlock the Offers",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed AnimatedWishlistButton class
class _AnimatedWishlistButton extends StatefulWidget {
  final Property property;

  const _AnimatedWishlistButton({required this.property});

  @override
  State<_AnimatedWishlistButton> createState() =>
      _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<_AnimatedWishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _onTap() async {
    // Use heavy impact for stronger vibration like Myntra
    HapticFeedback.heavyImpact();

    // Toggle wishlist state
    if (WishlistManager().isInWishlist(widget.property)) {
      WishlistManager().removeFromWishlist(widget.property);
    } else {
      WishlistManager().addToWishlist(widget.property);
    }

    // Reset and start animation
    _controller.reset();
    _controller.forward();

    // Force rebuild to update the icon
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = WishlistManager().isInWishlist(widget.property);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
              ),
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.redAccent : Colors.orange,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

class TabItem {
  final IconData? icon;
  final String? imagePath;
  final String label;

  TabItem({this.icon, this.imagePath, required this.label});
}

class CapsuleWaveLinePainter extends CustomPainter {
  final double centerX;
  final double capsuleWidth;
  final double capsuleHeight;
  final double borderRadius;

  CapsuleWaveLinePainter({
    required this.centerX,
    required this.capsuleWidth,
    required this.capsuleHeight,
    this.borderRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final leftX = centerX - capsuleWidth / 2;
    final rightX = centerX + capsuleWidth / 2;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(leftX, 0);
    path.arcToPoint(
      Offset(leftX + borderRadius, -borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(leftX + borderRadius, -capsuleHeight + borderRadius);
    path.arcToPoint(
      Offset(leftX + borderRadius * 2, -capsuleHeight),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rightX - borderRadius * 2, -capsuleHeight);
    path.arcToPoint(
      Offset(rightX - borderRadius, -capsuleHeight + borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rightX - borderRadius, -borderRadius);
    path.arcToPoint(
      Offset(rightX, 0),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    canvas.translate(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CapsuleWaveLinePainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.capsuleWidth != capsuleWidth ||
        oldDelegate.capsuleHeight != capsuleHeight ||
        oldDelegate.borderRadius != borderRadius;
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
          : [Color(0xFFE8ECFC), color!.withOpacity(0.8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    final path = Path();
    path.moveTo(0, 0);
    final double baseline = 28.0;
    final double crest = 46.0;
    final double trough = 12.0;
    path.lineTo(0, size.height - baseline);
    final double waveWidth = size.width / 3;
    path.quadraticBezierTo(
      waveWidth * 0.25,
      size.height - crest,
      waveWidth,
      size.height - baseline,
    );
    path.quadraticBezierTo(
      waveWidth * 1.5,
      size.height - trough,
      waveWidth * 2,
      size.height - baseline,
    );
    path.quadraticBezierTo(
      waveWidth * 2.75,
      size.height - crest,
      size.width,
      size.height - baseline,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TopGradientWavePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.startColor != startColor ||
      oldDelegate.endColor != endColor;
}

// Add these missing classes to make the code compile
class MockEnquiryRepository {}

class SubmitEnquiryUseCase {
  SubmitEnquiryUseCase(MockEnquiryRepository repository);
}
