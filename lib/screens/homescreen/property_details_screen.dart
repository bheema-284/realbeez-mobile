import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beez/screens/map_screens/map_with_booking_button.dart';
import 'package:real_beez/utils/app_colors.dart';

const Color kBackground = Color(0xFFF7F7FB);
const Color kPillBg = Color(0xFFEFEFEF);
const Color kIconGray = Color(0xFFA6A6A6);
const Color kSubtitleGray = Color(0xFF8C8C8C);
const Color kDescGray = Color(0xFF5E5E5E);
const Color kPriceGray = Color(0xFF242424);
const Color kGold = Color(0xFFFFD066);
const Color kImageError = Color(0xFFF0F0F0);

const double kMinTap = 44.0;

BoxShadow kCardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 12,
  offset: Offset(0, 6),
);

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({Key? key}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isDescriptionExpanded = false;
  bool _isBookmarked = false;
  bool _showAmenities = false;
  Set<int> _selectedAmenities = {};

  // Carousel state
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-sliding carousel
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_imagePageController.hasClients) {
        final nextIndex = (_currentImageIndex + 1) % 5; // assuming 5 images
        _imagePageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onImagePageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _toggleAmenitySelection(int index) {
    setState(() {
      if (_selectedAmenities.contains(index)) {
        _selectedAmenities.remove(index);
      } else {
        _selectedAmenities.add(index);
      }
    });
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Property'),
          content: Text('Share this property with others'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareViaWhatsApp(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message, color: Colors.green),
                  SizedBox(width: 8),
                  Text('WhatsApp'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareViaEmail(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Email'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyToClipboard(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Copy Link'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareViaWhatsApp(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening WhatsApp...')));
  }

  void _shareViaEmail(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening Email...')));
  }

  void _copyToClipboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Property link copied to clipboard!')),
    );
  }

  void _showBookmarkMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Property bookmarked!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openDirections(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to Ankura Villas, Gachibowli...'),
      ),
    );
  }

  void _makeCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call Property Agent'),
          content: Text('Would you like to call the property agent?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling +91 98765 43210...')),
                );
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  void _bookVisit(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book a Visit'),
          content: Text('Schedule a visit to Ankura Villas, Gachibowli'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Visit request submitted! We\'ll contact you soon.',
                    ),
                  ),
                );
              },
              child: Text('Book Visit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                // Hero image section
                SliverToBoxAdapter(
                  child: Container(
                    height: 280,
                    child: _HeroImageSection(
                      isBookmarked: _isBookmarked,
                      onBookmarkTap: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                        _showBookmarkMessage(context);
                      },
                      onShareTap: () {
                        _showShareDialog(context);
                      },
                      pageController: _imagePageController,
                      currentIndex: _currentImageIndex,
                      onPageChanged: _onImagePageChanged,
                    ),
                  ),
                ),

                // Property Info Card as a sliver
                SliverToBoxAdapter(
                  child: _PropertyInfoCard(
                    isDescriptionExpanded: _isDescriptionExpanded,
                    showAmenities: _showAmenities,
                    selectedAmenities: _selectedAmenities,
                    onReadMoreTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    onAmenitiesToggle: () {
                      setState(() {
                        _showAmenities = !_showAmenities;
                      });
                    },
                    onAmenityTap: _toggleAmenitySelection,
                    onDirectionTap: () => _openDirections(context),
                    onCallTap: () => _makeCall(context),
                    onBookVisitTap: () => _bookVisit(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------
// Hero Image Section with Carousel
// -----------------------
class _HeroImageSection extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onShareTap;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _HeroImageSection({
    Key? key,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onShareTap,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image Carousel
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: 5, // 5 sample images
          itemBuilder: (context, index) {
            return Image.asset(
              index % 2 == 0
                  ? 'assets/images/swipe1.png'
                  : 'assets/images/swipe.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: kImageError),
            );
          },
        ),

        // Carousel indicator dots - Positioned higher up
        Positioned(
          bottom: 40, // Moved up from 20 to 40
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? Colors.white : Colors.white54,
                ),
              );
            }),
          ),
        ),

        // translucent appbar + icons
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).maybePop(),
                background: Colors.black.withOpacity(0.35),
                iconColor: Colors.white,
                size: 42,
              ),

              Row(
                children: [
                  _SmallPillIcon(icon: Icons.share, onTap: onShareTap),
                  SizedBox(width: 8),
                  _SmallPillIcon(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    onTap: onBookmarkTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Circle icon used for back & other main icons
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color background;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.background = const Color(0x55000000),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: kGold.withOpacity(0.1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}

// small pill buttons on top right of image
class _SmallPillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallPillIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: kGold.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// -----------------------
// Property Info Card (now scrollable as part of main content)
// -----------------------
class _PropertyInfoCard extends StatelessWidget {
  final bool isDescriptionExpanded;
  final bool showAmenities;
  final Set<int> selectedAmenities;
  final VoidCallback onReadMoreTap;
  final VoidCallback onAmenitiesToggle;
  final ValueChanged<int> onAmenityTap;
  final VoidCallback onDirectionTap;
  final VoidCallback onCallTap;
  final VoidCallback onBookVisitTap;

  const _PropertyInfoCard({
    Key? key,
    required this.isDescriptionExpanded,
    required this.showAmenities,
    required this.selectedAmenities,
    required this.onReadMoreTap,
    required this.onAmenitiesToggle,
    required this.onAmenityTap,
    required this.onDirectionTap,
    required this.onCallTap,
    required this.onBookVisitTap,
  }) : super(key: key);

  // Short and full description
  String get _description => isDescriptionExpanded
      ? 'Experience luxury living in these spacious villas, designed with modern architecture, elegant interiors, and private green spaces. Each villa offers a perfect blend of comfort and sophistication, ideal for families seeking a serene lifestyle. These villas feature premium amenities including a swimming pool, gymnasium, children\'s play area, and 24/7 security. The location provides easy access to schools, hospitals, shopping centers, and major business districts.'
      : 'Experience luxury living in these spacious villas, designed with modern architecture, elegant interiors, and private green spaces. Each villa offers a perfect blend of comfort and sophistication, ideal for families seeking a serene lifestyle.';

  // All amenities asset paths
  List<String> get _amenitiesAssets => [
    'assets/icons/amenities.png',
    'assets/icons/amenities1.png',
    'assets/icons/amenities2.png',
    'assets/icons/amenities3.png',
    'assets/icons/amenities4.png',
    'assets/icons/amenities.png',
    'assets/icons/amenities1.png',
    'assets/icons/amenities4.png',
    'assets/icons/amenities3.png',
    'assets/icons/amenities.png',
    'assets/icons/amenities2.png',
    'assets/icons/amenities3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      shadowColor: Colors.black.withOpacity(0.15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location with Download Button in same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Ankura Villas',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: kPriceGray,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Gachibowli',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: kPriceGray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      // Download Brochure Button - Now in same row as location
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.beeYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            'Download Brochure',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Price Range Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range start from',
                        style: TextStyle(fontSize: 12, color: kSubtitleGray),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '80 Lakhs - 1 Cr',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPriceGray,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Description + Read More
                  Text(
                    _description,
                    style: TextStyle(
                      fontSize: 14,
                      color: kDescGray,
                      height: 1.4,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onReadMoreTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(44, 24),
                      ),
                      child: Text(
                        isDescriptionExpanded
                            ? 'Read Less....'
                            : 'Read More....',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.beeYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Our Amenities Section with Toggle
                  _AmenitiesSectionWithToggle(
                    showAmenities: showAmenities,
                    onToggle: onAmenitiesToggle,
                    amenitiesAssets: _amenitiesAssets,
                    selectedAmenities: selectedAmenities,
                    onAmenityTap: onAmenityTap,
                  ),

                  SizedBox(height: 24),

                  // Address Section
                  _SectionTitle('Address'),
                  SizedBox(height: 16),
                  _AddressSection(),

                  SizedBox(height: 24),

                  // RERA ID Section
                  _SectionTitle('RERA ID'),
                  SizedBox(height: 16),
                  _ReraSection(),

                  SizedBox(height: 24),

                  // About Building Section
                  _SectionTitle('About Building'),
                  SizedBox(height: 16),
                  _AboutBuildingSection(),

                  // Divider between sections
                  SizedBox(height: 24),
                  Divider(color: Colors.grey[300], height: 1),
                  SizedBox(height: 24),

                  // More Photos and Videos Section
                  _SectionTitle('More Photos and Videos'),
                  SizedBox(height: 12),
                  _PhotosCarousel(),

                  // Divider between sections
                  SizedBox(height: 24),
                  Divider(color: Colors.grey[300], height: 1),
                  SizedBox(height: 24),

                  // What Our Client's Say Section
                  _SectionTitle('What Our Client\'s Say!'),
                  TestimonialSection(),

                  // Bottom spacing before action buttons
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Action Buttons Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Navigation Button
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: onDirectionTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.beeYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  // Call Button (no space between)
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: onCallTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.beeYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ), // slight gap after icons
                      child: SizedBox(
                        height: 48,
                        width: 100,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.beeYellow,
                            side: const BorderSide(color: Color(0xFFE6E0D6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Book a Visit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
}

// NEW: Amenities Section with Toggle
class _AmenitiesSectionWithToggle extends StatelessWidget {
  final bool showAmenities;
  final VoidCallback onToggle;
  final List<String> amenitiesAssets;
  final Set<int> selectedAmenities;
  final ValueChanged<int> onAmenityTap;

  const _AmenitiesSectionWithToggle({
    required this.showAmenities,
    required this.onToggle,
    required this.amenitiesAssets,
    required this.selectedAmenities,
    required this.onAmenityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with toggle button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle('Our Amenities'),
            IconButton(
              onPressed: onToggle,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.beeYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  showAmenities ? Icons.remove : Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),

        // Amenities Grid (only shown when expanded)
        if (showAmenities) ...[
          _AmenitiesGrid(
            amenitiesAssets: amenitiesAssets,
            selectedAmenities: selectedAmenities,
            onAmenityTap: onAmenityTap,
          ),
          SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenitiesAssets;
  final Set<int> selectedAmenities;
  final ValueChanged<int> onAmenityTap;

  const _AmenitiesGrid({
    required this.amenitiesAssets,
    required this.selectedAmenities,
    required this.onAmenityTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: amenitiesAssets.length,
      itemBuilder: (context, index) {
        // Add null safety check
        if (index >= amenitiesAssets.length) {
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }

        final isSelected = selectedAmenities.contains(index);
        final assetPath = amenitiesAssets[index];

        return GestureDetector(
          onTap: () => onAmenityTap(index),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.beeYellow : Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.beeYellow : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: Image.asset(
                  assetPath,
                  color: isSelected ? Colors.white : Color(0xFF666666),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.error_outline,
                    color: isSelected ? Colors.white : Color(0xFF666666),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// NEW: Address Section - UPDATED with asset icons
class _AddressSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: Asia with location icon from assets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icons/globe.png', // Your location icon asset path
              width: 20,
              height: 20,
              color: AppColors.beeYellow,
              errorBuilder: (_, __, ___) => Icon(
                Icons.location_on_outlined,
                color: AppColors.beeYellow,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Asia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Second row: Address details with location icon from assets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icons/location.png', // Your location icon asset path
              width: 20,
              height: 20,
              color: AppColors.beeYellow,
              errorBuilder: (_, __, ___) => Icon(
                Icons.location_on_outlined,
                color: AppColors.beeYellow,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kphb, Hyderabad, Telangana, India, 500055',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// NEW: RERA ID Section - UPDATED
class _ReraSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, color: AppColors.beeYellow, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P02200000380',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.beeYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Check RERA Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

// NEW: About Building Section - UPDATED with separate icons for each item
class _AboutBuildingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: 2nd Block and 18 Floors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 2nd Block with its own icon
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/block_icon.png', // Icon for 2nd Block
                    width: 20,
                    height: 20,
                    color: AppColors.beeYellow,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.account_balance,
                      color: AppColors.beeYellow,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2nd Block',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '5 units',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 16), // Space between items
            // 18 Floors with its own icon
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/floors_icon.png', // Different icon for 18 Floors
                    width: 20,
                    height: 20,
                    color: AppColors.beeYellow,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.layers,
                      color: AppColors.beeYellow,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '18 Floors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '7th Floor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16), // Space between rows
        // Second row: 5 units and 7th Floor (if they need separate icons)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // If 5 units needs its own icon
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/units_icon.png', // Separate icon for units
                    width: 20,
                    height: 20,
                    color: AppColors.beeYellow,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.home, color: AppColors.beeYellow, size: 20),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5 units',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // If 7th Floor needs its own icon
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/current_floor_icon.png', // Separate icon for current floor
                    width: 20,
                    height: 20,
                    color: AppColors.beeYellow,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.arrow_upward,
                      color: AppColors.beeYellow,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7th Floor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// NEW: Building Info Item Widget
// ignore: unused_element
class _BuildingInfoItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BuildingInfoItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

// -----------------------
// Section Title
// -----------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

// -----------------------
// Photos Carousel (horizontal)
// -----------------------
class _PhotosCarousel extends StatelessWidget {
  const _PhotosCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      6,
      (i) =>
          i % 2 == 0 ? 'assets/images/swipe1.png' : 'assets/images/swipe.png',
    );
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        padding: EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          final url = items[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    url,
                    fit: BoxFit.cover,
                    width: 180,
                    errorBuilder: (_, __, ___) => Container(color: kImageError),
                  ),
                ),
                if (index == 1)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Testimonial {
  final String text;
  final String name;
  final String profileAsset;
  final String videoAsset;

  Testimonial({
    required this.text,
    required this.name,
    required this.profileAsset,
    required this.videoAsset,
  });
}

class TestimonialSection extends StatefulWidget {
  const TestimonialSection({super.key});

  @override
  State<TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends State<TestimonialSection> {
  final PageController _pageController = PageController();
  int activeIndex = 0;

  final List<Testimonial> testimonials = [
    Testimonial(
      text:
          "Working with their team was a delight! They delivered beyond expectations and the quality is unmatched.",
      name: "Sophie",
      profileAsset: "assets/profile1.jpg",
      videoAsset: "assets/video1.mp4",
    ),
    Testimonial(
      text:
          "Excellent service, professional approach, and the outcome was simply stunning!",
      name: "Michael",
      profileAsset: "assets/profile2.jpg",
      videoAsset: "assets/video2.mp4",
    ),
    Testimonial(
      text:
          "They truly understood our vision and turned it into reality. Highly recommend their work!",
      name: "Ava",
      profileAsset: "assets/profile3.jpg",
      videoAsset: "assets/video3.mp4",
    ),
  ];

  late List<VideoPlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = testimonials
        .map(
          (t) =>
              VideoPlayerController.asset(t.videoAsset)
                ..initialize().then((_) => setState(() {})),
        )
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildVideo(int index) {
    final controller = _controllers[index];
    if (controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Image.asset(testimonials[index].profileAsset, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.85;
    final leftWidth = cardWidth * 0.5;
    final rightWidth = cardWidth * 0.5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          width: cardWidth,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                activeIndex = index;
              });
            },
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// LEFT — Video (Full height)
                  SizedBox(
                    width: leftWidth,
                    height: 260,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildVideo(index),
                          Container(color: Colors.black26),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                final controller = _controllers[index];
                                if (controller.value.isInitialized) {
                                  controller.value.isPlaying
                                      ? controller.pause()
                                      : controller.play();
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controllers[index].value.isInitialized &&
                                          _controllers[index].value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 34,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// RIGHT — Text (shorter)
                  SizedBox(
                    width: rightWidth,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 180, // ✅ shorter than video
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  testimonials[index].text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      testimonials[index].name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: List.generate(3, (i) {
                                        return const Padding(
                                          padding: EdgeInsets.only(right: 2.0),
                                          child: Icon(
                                            Icons.star,
                                            size: 17,
                                            color: Color(0xFFFFC107),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        testimonials[index].profileAsset,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ------------------------
        // Dots Indicator
        // ------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(testimonials.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: activeIndex == index ? 10 : 8,
              height: activeIndex == index ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeIndex == index ? Colors.black87 : Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }
}
