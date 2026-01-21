import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';

void main() {
  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate Search - Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFF061021),
        fontFamily: 'Roboto',
      ),
      home: const RealEstateHome(),
    );
  }
}

class RealEstateHome extends StatefulWidget {
  const RealEstateHome({super.key});

  @override
  State<RealEstateHome> createState() => _RealEstateHomeState();
}

class _RealEstateHomeState extends State<RealEstateHome> {
  // For carousel
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _activePage = 0;

  // Google Map controller and state
  // ignore: deprecated_member_use
  MaplibreMapController? _mapController;
  final List<Symbol> _symbols = <Symbol>[];
  static final LatLng _defaultCenter = LatLng(17.4474, 78.3919); // Madhapur
  static const double _defaultZoom = 13.5;

  // Listings around Madhapur (demo data)
  final List<_Listing> _listings = [
    _Listing(
      id: 'ankura',
      title: 'Ankura Plots',
      subtitle: 'Gachibowli',
      position: LatLng(17.4401, 78.3489),
      isNew: true,
      tags: {'Apartments'},
    ),
    _Listing(
      id: 'raidurg',
      title: 'Skyline Residency',
      subtitle: 'Raidurg',
      position: LatLng(17.4359, 78.4044),
      tags: {'Trending', 'Apartments'},
    ),
    _Listing(
      id: 'hitec',
      title: 'Hitec Heights',
      subtitle: 'HITEC City',
      position: LatLng(17.4504, 78.3813),
      tags: {'Villas'},
    ),
    _Listing(
      id: 'ikea',
      title: 'IKEA Surroundings',
      subtitle: 'Kukatpally',
      position: LatLng(17.4561, 78.3560),
      tags: {'Trending', 'Villas'},
    ),
    _Listing(
      id: 'cybercity',
      title: 'Cyber City Towers',
      subtitle: 'Cyberabad',
      position: LatLng(17.4419, 78.3489),
      isNew: true,
      tags: {'Newly', 'Apartments'},
    ),
    _Listing(
      id: 'techpark',
      title: 'Tech Park Villas',
      subtitle: 'Madhapur',
      position: LatLng(17.4480, 78.3950),
      tags: {'Trending', 'Villas'},
    ),
    _Listing(
      id: 'startup',
      title: 'Startup Hub Residences',
      subtitle: 'Gachibowli',
      position: LatLng(17.4420, 78.3500),
      isNew: true,
      tags: {'Newly', 'Trending', 'Apartments'},
    ),
    _Listing(
      id: 'luxury',
      title: 'Luxury Estates',
      subtitle: 'HITEC City',
      position: LatLng(17.4510, 78.3820),
      tags: {'Villas'},
    ),
  ];

  // Active filters
  final Set<String> _activeFilters = <String>{};

  List<_Listing> get _filteredListings {
    if (_activeFilters.isEmpty) return _listings;

    return _listings.where((listing) {
      // Check if "Newly" filter is active and listing is new
      if (_activeFilters.contains('Newly') && !listing.isNew) return false;

      // Get all other filters (excluding 'Newly' and 'Filter')
      final Set<String> tagFilters = _activeFilters.difference({
        'Filter',
        'Newly',
      });

      // If no tag filters, only check "Newly" filter
      if (tagFilters.isEmpty) return true;

      // Check if listing has any of the selected tags
      return listing.tags.intersection(tagFilters).isNotEmpty;
    }).toList();
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
      } else {
        _activeFilters.add(label);
      }
      _renderMarkers();
      if (_filteredListings.isNotEmpty) {
        _pageController.jumpToPage(0);
        _animateToListing(0);
      }
    });
  }

  // Add this method to handle navigation
  void _navigateToHomeScreen(_Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PropertyDetailScreen(propertyId: listing.id.toString()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_activePage != next) {
        setState(() => _activePage = next);
        _animateToListing(next);
      }
    });
    _ensureLocationPermission();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // ignore: deprecated_member_use
  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;
    _renderMarkers();
    _animateToListing(_activePage);
  }

  Future<void> _renderMarkers() async {
    if (_mapController == null) return;
    // Clear existing
    for (final s in List<Symbol>.from(_symbols)) {
      await _mapController!.removeSymbol(s);
    }
    _symbols.clear();

    final List<_Listing> source = _filteredListings;
    for (final listing in source) {
      final symbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: listing.position,
          iconImage: 'marker-15',
          iconSize: 1.2,
          textField: listing.title,
          textSize: 10.0,
          textOffset: const Offset(0, 1.5),
        ),
      );
      _symbols.add(symbol);
    }
  }

  Future<void> _animateToListing(int index) async {
    if (_mapController == null) return;
    final list = _filteredListings;
    if (index < 0 || index >= list.length) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: list[index].position, zoom: _defaultZoom),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Location "dropdown"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Madhapur, Hyderabad, TG',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = [
      {'label': 'Filter', 'icon': Icons.filter_list},
      {'label': 'Newly', 'icon': null},
      {'label': 'Trending', 'icon': null},
      {'label': 'Apartments', 'icon': null},
      {'label': 'Villas', 'icon': null},
    ];

    Color chipColor(String label, bool selected) {
      // ignore: deprecated_member_use
      if (label == 'Filter')
        return selected
            ? const Color(0xFFFFD98B)
            : Colors.white.withOpacity(0.06);
      // ignore: deprecated_member_use
      return selected
          ? const Color(0xFFFFD98B)
          : Colors.white.withOpacity(0.06);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final String label = f['label']!.toString();
          final bool selected = _activeFilters.contains(label);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: _FilterChipButton(
              label: label,
              icon: f['icon'] as IconData?,
              selected: selected,
              onPressed: () async {
                if (label == 'Filter') {
                  _openFilterBottomSheet();
                } else {
                  _toggleFilter(label);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipColor(label, selected),
                  borderRadius: BorderRadius.circular(24),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    if (f['icon'] != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          f['icon'] as IconData,
                          size: 16,
                          color: selected ? Colors.black87 : Colors.white,
                        ),
                      ),
                    Text(
                      label == 'Filter' && _activeFilters.isNotEmpty
                          ? 'Filter (${_activeFilters.length})'
                          : label,
                      style: TextStyle(
                        color: selected ? Colors.black87 : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openFilterBottomSheet() async {
    // Create separate sets for each section
    final Map<String, Set<String>> sectionSelections = {
      'Top Picks': <String>{},
      'Trending': <String>{},
      'Deals': <String>{},
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              top: false,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202B36),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _filterSection(
                          'Top Picks',
                          sectionSelections['Top Picks']!,
                          () => setModalState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _filterSection(
                          'Trending',
                          sectionSelections['Trending']!,
                          () => setModalState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _filterSection(
                          'Deals',
                          sectionSelections['Deals']!,
                          () => setModalState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Clear all sections independently
                                  sectionSelections.forEach((key, value) {
                                    value.clear();
                                  });
                                  setModalState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  // ignore: deprecated_member_use
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Clear All'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();

                                  // Combine all section selections
                                  final combinedFilters = <String>{};
                                  sectionSelections.forEach((section, filters) {
                                    combinedFilters.addAll(filters);
                                  });

                                  setState(() {
                                    _activeFilters
                                      ..clear()
                                      ..addAll(combinedFilters);
                                    _renderMarkers();
                                    if (_filteredListings.isNotEmpty) {
                                      _pageController.jumpToPage(0);
                                      _animateToListing(0);
                                    }
                                  });

                                  // Show feedback to user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        combinedFilters.isEmpty
                                            ? 'All filters cleared'
                                            : '${combinedFilters.length} filter(s) applied - ${_filteredListings.length} properties found',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF202B36),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD98B),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Floating close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterSection(
    String title,
    Set<String> sectionFilters,
    void Function() refresh,
  ) {
    // Completely different options for each section
    List<String> options;
    switch (title) {
      case 'Top Picks':
        options = const ['Premium', 'Luxury', 'New Launch', 'Best Value'];
        break;
      case 'Trending':
        options = const ['Hot Deal', 'Most Viewed', 'Fast Selling', 'Popular'];
        break;
      case 'Deals':
        options = const [
          'Discount',
          'Limited Offer',
          'Special Price',
          'Bundle',
        ];
        break;
      default:
        options = const ['Newly', 'Trending', 'Apartments', 'Villas'];
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3642),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            // ignore: deprecated_member_use
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((label) {
              return _filterChip(
                label,
                sectionFilters.contains(label),
                onTap: () {
                  if (sectionFilters.contains(label)) {
                    sectionFilters.remove(label);
                  } else {
                    sectionFilters.add(label);
                  }
                  refresh();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    bool selected, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD98B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.black12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black87 : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMapArea(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Positioned.fill(
            // ignore: deprecated_member_use
            child: MaplibreMap(
              initialCameraPosition: CameraPosition(
                target: _defaultCenter,
                zoom: _defaultZoom,
              ),
              onMapCreated: _onMapCreated,
              styleString:
                  'https://api.maptiler.com/maps/streets/style.json?key=805101f1dec8c8442fbd1aa342fa42ad',
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.none,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
            ),
          ),

          // ignore: deprecated_member_use
          Positioned(
            top: 22,
            left: 16,
            child: Text(
              'PHASE 2',
              style: TextStyle(
                color: Colors.white.withOpacity(0.08),
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(int index, bool active) {
    // Card sizes vary a bit when active
    final double scale = active ? 1.0 : 0.94;
    final listing = _filteredListings[index % _filteredListings.length];

    return GestureDetector(
      onTap: () => _navigateToHomeScreen(listing),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title + actions - Very compact
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  4,
                ), // Even more compact
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2), // Minimal spacing
                          Text(
                            listing.subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // circular gold icons
                    _goldCircleIcon(Icons.favorite_border),
                  ],
                ),
              ),

              // Price row + 'New' badge - Very compact
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                child: Row(
                  children: [
                    if (listing.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD98B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (listing.isNew) const SizedBox(width: 6),
                    const Text(
                      'Price Range start from:',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Price value - Minimal spacing
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 4),
                child: Text(
                  '80 Lakhs - 1 Crs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200, // Maximum image height
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    child: Image.asset(
                      'assets/images/farmland1.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldCircleIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD98B),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarPadding = MediaQuery.of(context).padding.top;
    final bottomCardHeight = MediaQuery.of(context).size.height * 0.30;

    return Scaffold(
      backgroundColor: const Color(0xFF061021),
      body: SafeArea(
        child: Column(
          children: [
            // Simulated status bar (visual)
            SizedBox(height: statusBarPadding),

            // Top bar and filters
            _buildTopBar(),
            _buildFilterRow(),

            // Map Area - expands
            _buildMapArea(context),

            // Carousel listing bottom 30%
            SizedBox(
              height: bottomCardHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _filteredListings.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final active = index == _activePage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildListingCard(index, active),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;
  const _FilterChipButton({
    required this.label,
    this.icon,
    required this.selected,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

class _Listing {
  final String id;
  final String title;
  final String subtitle;
  final LatLng position;
  final bool isNew;
  final Set<String> tags; // e.g., {"Trending", "Apartments"}
  const _Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    this.isNew = false,
    this.tags = const {},
  });
}
