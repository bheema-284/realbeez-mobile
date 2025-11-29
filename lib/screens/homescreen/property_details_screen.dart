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
  final String propertyId;

  const PropertyDetailScreen({Key? key, required this.propertyId}) : super(key: key);

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

  // Property data based on ID
  Map<String, dynamic> get _propertyData {
    final properties = {
      'prop_001': {
        'title': 'Sky View Villas',
        'location': 'Jubilee Hills, Hyderabad',
        'priceRange': '3.5 Cr – 5.2 Cr',
        'description': 'Experience luxury living in these spacious villas, designed with modern architecture, elegant interiors, and private green spaces. Each villa offers a perfect blend of comfort and sophistication, ideal for families seeking a serene lifestyle. These villas feature premium amenities including a swimming pool, gymnasium, children\'s play area, and 24/7 security. The location provides easy access to schools, hospitals, shopping centers, and major business districts.',
        'reraId': 'P02200000380',
        'address': 'Jubilee Hills, Hyderabad, Telangana, India, 500085',
        'phone': '+91 98765 43210',
      },
      'prop_002': {
        'title': 'Urban Sky Apartments',
        'location': 'Financial District, Hyderabad',
        'priceRange': '2.8 Cr – 4.2 Cr',
        'description': 'Modern apartments with premium amenities in the heart of the financial district. These apartments feature state-of-the-art facilities including a rooftop garden, fitness center, and smart home automation. Perfect for professionals seeking luxury and convenience with stunning city views and easy access to corporate offices and entertainment hubs.',
        'reraId': 'P02200000381',
        'address': 'Financial District, Hyderabad, Telangana, India, 500032',
        'phone': '+91 98765 43211',
      },
      'prop_003': {
        'title': 'Prestige High Fields',
        'location': 'Gachibowli, Hyderabad',
        'priceRange': '1.8 Cr – 2.5 Cr',
        'description': 'Under construction property with great potential for investment and future living. Located in the rapidly developing Gachibowli area, these properties offer modern amenities and strategic location advantages. The project includes recreational facilities, commercial spaces, and excellent connectivity to IT hubs and educational institutions.',
        'reraId': 'P02200000382',
        'address': 'Gachibowli, Hyderabad, Telangana, India, 500032',
        'phone': '+91 98765 43212',
      },
      'prop_004': {
        'title': 'Green Valley Community',
        'location': 'Hitech City, Hyderabad',
        'priceRange': '2.2 Cr – 3.8 Cr',
        'description': 'A peaceful community living experience in the bustling Hitech City area. These properties offer the perfect balance between urban convenience and natural surroundings. The community features landscaped gardens, walking tracks, community centers, and excellent security systems for a comfortable family lifestyle.',
        'reraId': 'P02200000383',
        'address': 'Hitech City, Hyderabad, Telangana, India, 500081',
        'phone': '+91 98765 43213',
      },
      'prop_005': {
        'title': 'Elite Penthouse Residences',
        'location': 'Banjara Hills, Hyderabad',
        'priceRange': '4.5 Cr – 6.8 Cr',
        'description': 'Ultra-luxury penthouse residences offering panoramic city views and exclusive amenities. These penthouses feature private terraces, Jacuzzis, premium finishes, and personalized services. Located in the most prestigious neighborhood, they offer privacy, security, and unmatched luxury for discerning buyers.',
        'reraId': 'P02200000384',
        'address': 'Banjara Hills, Hyderabad, Telangana, India, 500034',
        'phone': '+91 98765 43214',
      },
      'prop_006': {
        'title': 'Royal Garden Estates',
        'location': 'Kokapet, Hyderabad',
        'priceRange': '1.5 Cr – 2.2 Cr',
        'description': 'Gated community living with extensive green spaces and family-friendly amenities. These estates offer spacious homes with modern designs, community parks, sports facilities, and shopping areas within the complex. Perfect for families looking for a secure and vibrant community environment.',
        'reraId': 'P02200000385',
        'address': 'Kokapet, Hyderabad, Telangana, India, 500075',
        'phone': '+91 98765 43215',
      },
      'prop_007': {
        'title': 'Tech Park Commercial',
        'location': 'Raidurg, Hyderabad',
        'priceRange': '8.5 Cr – 12 Cr',
        'description': 'Premium commercial spaces in the heart of the technology corridor. These commercial properties offer excellent visibility, modern infrastructure, and strategic location advantages for businesses. Features include ample parking, high-speed elevators, modern security systems, and flexible office layouts suitable for various business needs.',
        'reraId': 'P02200000386',
        'address': 'Raidurg, Hyderabad, Telangana, India, 500032',
        'phone': '+91 98765 43216',
      },
    };

    return properties[widget.propertyId] ?? {
      'title': 'Ankura Villas',
      'location': 'Gachibowli',
      'priceRange': '80 Lakhs - 1 Cr',
      'description': 'Experience luxury living in these spacious villas, designed with modern architecture, elegant interiors, and private green spaces. Each villa offers a perfect blend of comfort and sophistication, ideal for families seeking a serene lifestyle. These villas feature premium amenities including a swimming pool, gymnasium, children\'s play area, and 24/7 security. The location provides easy access to schools, hospitals, shopping centers, and major business districts.',
      'reraId': 'P02200000380',
      'address': 'Kphb, Hyderabad, Telangana, India, 500055',
      'phone': '+91 98765 43210',
    };
  }

  @override
  void initState() {
    super.initState();
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
        final nextIndex = (_currentImageIndex + 1) % 5;
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
          content: Text('Share ${_propertyData['title']} with others'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening WhatsApp...')),
    );
  }

  void _shareViaEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Email...')),
    );
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
      SnackBar(content: Text('Opening directions to ${_propertyData['title']}, ${_propertyData['location']}...')),
    );
  }

  void _makeCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call Property Agent'),
          content: Text('Would you like to call the property agent for ${_propertyData['title']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${_propertyData['phone']}...')),
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
          content: Text('Schedule a visit to ${_propertyData['title']}, ${_propertyData['location']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Visit request submitted! We\'ll contact you soon.')),
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
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 320,
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
                
                // Add empty space for the overlapping card
                SliverToBoxAdapter(
                  child: SizedBox(height: 280), // This creates space for the overlapping card
                ),
              ],
            ),
            
            // Positioned Property Info Card that overlaps the image
            Positioned(
              top: 280, // Position from top to overlap the image carousel
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView( // Make the card scrollable
                child: _PropertyInfoCard(
                  propertyData: _propertyData,
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
            ),
          ],
        ),
      ),
    );
  }
}

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
        // Main image carousel
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Image.asset(
              index % 2 == 0 ? 'assets/images/swipe1.png' : 'assets/images/swipe.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: kImageError),
            );
          },
        ),

        // Bottom indicators - positioned at the very bottom of the container
        Positioned(
          bottom: 70, // Positioned higher to be visible above the overlapping card
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? Colors.white : Colors.white54,
                ),
              );
            }),
          ),
        ),

        // Top action buttons
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
                  _SmallPillIcon(
                    icon: Icons.share,
                    onTap: onShareTap,
                  ),
                  SizedBox(width: 8),
                  _SmallPillIcon(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    onTap: onBookmarkTap,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

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
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}

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

class _PropertyInfoCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;
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
    required this.propertyData,
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

  String get _description => isDescriptionExpanded
      ? propertyData['description']
      : propertyData['description'].length > 200
          ? '${propertyData['description'].substring(0, 200)}...'
          : propertyData['description'];

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
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyData['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
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
                                    propertyData['location'],
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
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.beeYellow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range start from',
                        style: TextStyle(
                          fontSize: 12,
                          color: kSubtitleGray,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        propertyData['priceRange'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPriceGray,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),

                  Text(
                    _description,
                    style: TextStyle(fontSize: 14, color: kDescGray, height: 1.4),
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
                        isDescriptionExpanded ? 'Read Less....' : 'Read More....',
                        style: TextStyle(fontSize: 14, color: AppColors.beeYellow, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                

                  _AmenitiesSectionWithToggle(
                    showAmenities: showAmenities,
                    onToggle: onAmenitiesToggle,
                    amenitiesAssets: _amenitiesAssets,
                    selectedAmenities: selectedAmenities,
                    onAmenityTap: onAmenityTap,
                  ),

                  SizedBox(height: 8),
                  
                  _SectionTitle('Address'),
                  SizedBox(height: 16),
                  _AddressSection(address: propertyData['address']),

                  SizedBox(height: 24),
                  
                  _SectionTitle('RERA ID'),
                  SizedBox(height: 16),
                  _ReraSection(reraId: propertyData['reraId']),

                  SizedBox(height: 24),
                  
                  _SectionTitle('About Building'),
                  SizedBox(height: 16),
                  _AboutBuildingSection(),

               
                  SizedBox(height: 24),

                  _SectionTitle('More Photos and Videos'),
                  SizedBox(height: 12),
                  PhotosVideosCarouselWithDots(),

                  SizedBox(height: 24),
              _SectionTitle('Floor Plans and Broucher'),
                  SizedBox(height: 12),
                  _FloorPlansCarousel(),

                  SizedBox(height: 24),

                  _SectionTitle('What Our Client\'s Say!'),
                  TestimonialSection(),

                  SizedBox(height: 20),
                ],
              ),
            ),
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
      SizedBox(
        height: 48,
        width: 48,
        child: ElevatedButton(
          onPressed: onDirectionTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.beeYellow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      SizedBox(
        height: 48,
        width: 48,
        child: ElevatedButton(
          onPressed: onCallTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.beeYellow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            height: 48,
            width: 100,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.beeYellow,
                side: const BorderSide(color: Color(0xFFE6E0D6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class PhotosVideosCarouselWithDots extends StatefulWidget {
  const PhotosVideosCarouselWithDots({Key? key}) : super(key: key);

  @override
  State<PhotosVideosCarouselWithDots> createState() => _PhotosVideosCarouselWithDotsState();
}

class _PhotosVideosCarouselWithDotsState extends State<PhotosVideosCarouselWithDots> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  final List<Map<String, String>> _mediaItems = [
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400&h=300&fit=crop',
    },
    {
      'type': 'video',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop',
    },
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop',
    },
    {
      'type': 'video',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    },
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=400&h=300&fit=crop',
    },
  ];

  // Track video controllers
  late List<VideoPlayerController?> _videoControllers;
  late List<bool> _isVideoInitialized;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize video controllers
    _videoControllers = List.generate(_mediaItems.length, (index) => null);
    _isVideoInitialized = List.filled(_mediaItems.length, false);
    
    // Pre-initialize video controllers for video items
    for (int i = 0; i < _mediaItems.length; i++) {
      if (_mediaItems[i]['type'] == 'video') {
        _initializeVideoController(i);
      }
    }
  }

  void _initializeVideoController(int index) {
    _videoControllers[index] = VideoPlayerController.network(_mediaItems[index]['url']!)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized[index] = true;
          });
          _videoControllers[index]!.setLooping(true);
          // Auto-play if this is the current page
          if (index == _currentPage) {
            _videoControllers[index]!.play();
          }
        }
      });
  }

  void _onScroll() {
    final scrollPosition = _scrollController.position;
    final pageWidth = MediaQuery.of(context).size.width * 0.8;
    final newPage = (scrollPosition.pixels / pageWidth).round();
    
    if (newPage != _currentPage) {
      // Pause videos that are no longer in view
      _pauseAllVideos();
      
      setState(() {
        _currentPage = newPage;
      });
      
      // Play the new current video if it's a video
      _playCurrentVideo();
    }
  }

  void _pauseAllVideos() {
    for (int i = 0; i < _videoControllers.length; i++) {
      if (_videoControllers[i] != null && 
          _isVideoInitialized[i] && 
          _videoControllers[i]!.value.isPlaying) {
        _videoControllers[i]!.pause();
      }
    }
  }

  void _playCurrentVideo() {
    if (_currentPage < _mediaItems.length && 
        _mediaItems[_currentPage]['type'] == 'video' &&
        _videoControllers[_currentPage] != null &&
        _isVideoInitialized[_currentPage] &&
        !_videoControllers[_currentPage]!.value.isPlaying) {
      _videoControllers[_currentPage]!.play();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8;
    final itemHeight = itemWidth * 0.8;

    return Column(
      children: [
        // Horizontal scrollable carousel
        Container(
          height: itemHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _mediaItems.length,
            separatorBuilder: (context, index) => SizedBox(width: 12),
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final item = _mediaItems[index];
              final isVideo = item['type'] == 'video';
              
              return Container(
                width: itemWidth,
                height: itemHeight,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? _VideoPlayerItem(
                            videoController: _videoControllers[index],
                            isInitialized: _isVideoInitialized[index],
                          )
                        : Image.network(
                            item['url']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: kImageError,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 12),
        
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_mediaItems.length, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 8 : 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index ? AppColors.beeYellow : Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VideoPlayerItem extends StatelessWidget {
  final VideoPlayerController? videoController;
  final bool isInitialized;

  const _VideoPlayerItem({
    required this.videoController,
    required this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || videoController == null) {
      return Container(
        color: Colors.black12,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.beeYellow),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoController!.value.size.width,
          height: videoController!.value.size.height,
          child: VideoPlayer(videoController!),
        ),
      ),
    );
  }
}

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

class _AddressSection extends StatelessWidget {
  final String address;

  const _AddressSection({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public,
              color: AppColors.beeYellow,
              size: 20,
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
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppColors.beeYellow,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReraSection extends StatelessWidget {
  final String reraId;

  const _ReraSection({required this.reraId});

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
          Icon(
            Icons.verified_outlined,
            color: AppColors.beeYellow,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reraId,
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

class _AboutBuildingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: AppColors.beeYellow,
                    size: 20,
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
            
            SizedBox(width: 16),
            
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.layers,
                    color: AppColors.beeYellow,
                    size: 20,
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
        
        SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: AppColors.beeYellow,
                    size: 20,
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
            
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: AppColors.beeYellow,
                    size: 20,
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
    );
  }
}

class _FloorPlansCarousel extends StatelessWidget {
  const _FloorPlansCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floorPlans = [
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      },
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1617104424035-1d5e204f2599?w=400&h=300&fit=crop',
      },
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1617104424038-e04d5ef70b47?w=400&h=300&fit=crop',
      },
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1617104424106-37c6fb006b79?w=400&h=300&fit=crop',
      },
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1617104424035-1d5e204f2599?w=400&h=300&fit=crop',
      },
      {
        'type': 'image',
        'url': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8;
    final itemHeight = itemWidth * 0.8;

    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: floorPlans.length,
        separatorBuilder: (_, __) => SizedBox(width: 16),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = floorPlans[index];
          
          return Container(
            width: itemWidth,
            height: itemHeight,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['url']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: kImageError,
                  ),
                ),
              ),
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
      profileAsset: "assets/images/profile1.jpg",
      videoAsset: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    ),
    Testimonial(
      text:
          "Excellent service, professional approach, and the outcome was simply stunning!",
      name: "Michael",
      profileAsset: "assets/images/profile2.jpg",
      videoAsset: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    ),
    Testimonial(
      text:
          "They truly understood our vision and turned it into reality. Highly recommend their work!",
      name: "Ava",
      profileAsset: "assets/images/profile3.jpg",
      videoAsset: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    ),
  ];

  late List<VideoPlayerController> _controllers;
  late List<bool> _isVideoInitialized;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _isVideoInitialized = List.filled(testimonials.length, false);
    
    // Initialize video controllers
    for (int i = 0; i < testimonials.length; i++) {
      final controller = VideoPlayerController.network(testimonials[i].videoAsset);
      _controllers.add(controller);
      
      controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized[i] = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildVideo(int index) {
  final controller = _controllers[index];
  if (_isVideoInitialized[index]) {
    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        Container(color: Colors.black26),
      ],
    );
  } else {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.beeYellow),
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final leftWidth = cardWidth * 0.5;
    final rightWidth = cardWidth * 0.5;
    final cardHeight = cardWidth * 0.7;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: cardHeight,
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
                 SizedBox(
  width: leftWidth,
  height: cardHeight,
  child: ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        _buildVideo(index),
        Center(
          child: GestureDetector(
            onTap: () {
              final controller = _controllers[index];
              if (_isVideoInitialized[index]) {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              }
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isVideoInitialized[index] && 
                _controllers[index].value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

                  SizedBox(
                    width: rightWidth,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: cardHeight * 0.7,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
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
                                          padding:
                                              EdgeInsets.only(right: 2.0),
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
                                        color: Colors.white, width: 2),
                                    color: Colors.grey[400],
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                    size: 24,
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(testimonials.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: activeIndex == index ? 4 : 6,
              height: activeIndex == index ? 4 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    activeIndex == index ? AppColors.beeYellow : Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PropertyDetailScreen(propertyId: 'prop_001'),
  ));
}