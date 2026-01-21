import 'dart:math';

import 'package:flutter/material.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/models/property.dart';
import 'package:real_beez/screens/repositories/property_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

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

  // For search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<MapSearchResult> _searchResults = [];
  String _currentAddress = 'Madhapur, Hyderabad, TG';
  LatLng? _currentLocation;

  // For loading state
  bool _isLoadingLocation = false;

  // Map controller and state
  MapController _mapController = MapController();
  double _currentZoom = 13.5;

  // Track selected pin location
  LatLng? _selectedPinLocation;
  String? _selectedPinTitle;

  // Property repository for loading data
  final PropertyRepository _propertyRepository = PropertyRepository();
  List<Property> _properties = [];
  bool _isLoading = true;

  // Convert properties to _Listing format
  List<_Listing> get _listings {
    return _properties.map((property) {
      final address = property.address;
      final tags = _getTagsFromProperty(property);

      return _Listing(
        id: property.id.toString(),
        title: property.title,
        subtitle: '${address.area}, ${address.city}',
        position: LatLng(address.latitude, address.longitude),
        isNew:
            property.status == 'pre_launch' ||
            property.status == 'under_construction',
        tags: tags,
        property: property, // Store the property for details
      );
    }).toList();
  }

  // Helper method to create tags from Property
  Set<String> _getTagsFromProperty(Property property) {
    final Set<String> tags = <String>{};

    // Add type as tag
    if (property.type == 'villa') {
      tags.add('Villas');
    } else if (property.type == 'apartment') {
      tags.add('Apartments');
    }

    // Add status-based tags
    if (property.status == 'pre_launch' ||
        property.status == 'under_construction') {
      tags.add('Newly');
    }

    // Add trending based on some criteria
    if (property.price > 8000000) {
      tags.add('Trending');
    }

    // Add amenity-based tags
    if (property.amenities.contains('swimming_pool') ||
        property.amenities.contains('clubhouse')) {
      tags.add('Premium');
    }

    return tags;
  }

  // Active filters
  final Set<String> _activeFilters = <String>{};

  // Calculate distance between two coordinates in km
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // km

    double lat1 = pos1.latitude * (3.141592653589793 / 180);
    double lon1 = pos1.longitude * (3.141592653589793 / 180);
    double lat2 = pos2.latitude * (3.141592653589793 / 180);
    double lon2 = pos2.longitude * (3.141592653589793 / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Get listings filtered by tags AND proximity to selected pin
  List<_Listing> get _filteredListings {
    // First filter by tags
    List<_Listing> tagFiltered = _listings.where((listing) {
      if (_activeFilters.isEmpty) return true;

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

    // If a pin is selected, show only nearby properties (within 2km radius)
    if (_selectedPinLocation != null) {
      return tagFiltered.where((listing) {
        double distance = _calculateDistance(
          _selectedPinLocation!,
          listing.position,
        );
        return distance <= 2.0; // 2km radius
      }).toList();
    }

    // If no pin selected, show all properties
    return tagFiltered;
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
      } else {
        _activeFilters.add(label);
      }
      if (_filteredListings.isNotEmpty) {
        _pageController.jumpToPage(0);
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
      }
    });
    _loadProperties();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await _propertyRepository.loadProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // For demo, we'll use a fixed location (Madhapur)
      _currentLocation = LatLng(17.4474, 78.3919);

      // Reverse geocode to get address
      final address = await _reverseGeocode(_currentLocation!);

      setState(() {
        _currentAddress = address;
      });

      // Move map to current location
      _mapController.move(
        latlong.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        12, // Zoom out to see all 9 properties
      );
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<String> _reverseGeocode(LatLng latLng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};

        // Extract city/town for better display
        final String? city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['suburb'] ??
            'Unknown Location';

        final String? state = address['state'] ?? '';

        return '$city${(state?.isNotEmpty ?? false) ? ', $state' : ''}';
      }
    } catch (e) {
      print('Reverse geocode error: $e');
    }

    return 'Unknown Location';
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeQueryComponent(query)}&limit=10&countrycodes=in',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) {
            return MapSearchResult(
              displayName: item['display_name'],
              lat: double.parse(item['lat']),
              lon: double.parse(item['lon']),
              type: item['type'] ?? 'unknown',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onLocationSelected(MapSearchResult result) {
    setState(() {
      _currentAddress = _truncateDisplayName(result.displayName);
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
      _selectedPinLocation =
          null; // Clear selected pin when searching new location
    });

    // Move map to selected location
    final selectedLatLng = latlong.LatLng(result.lat, result.lon);
    _mapController.move(selectedLatLng, 12);

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location updated to: ${result.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPinSelected(_Listing listing) {
    setState(() {
      _selectedPinLocation = listing.position;
      _selectedPinTitle = listing.title;
    });

    final latLng = latlong.LatLng(
      listing.position.latitude,
      listing.position.longitude,
    );

    // Smooth zoom to property
    _mapController.move(latLng, 15);

    // Reset carousel to first page
    if (_filteredListings.isNotEmpty) {
      _pageController.jumpToPage(0);
      setState(() {
        _activePage = 0;
      });
    }

    // Show info about how many properties nearby
    final nearbyCount = _filteredListings.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nearbyCount properties near ${listing.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearPinSelection() {
    setState(() {
      _selectedPinLocation = null;
      _selectedPinTitle = null;
    });

    // Zoom back out to show all properties
    _mapController.move(latlong.LatLng(17.4474, 78.3919), 12);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Search Bar
          Container(
            child: Row(
              children: [
                const SizedBox(width: 10),
                if (!_isSearching)
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      width: 44,
                      height: 30,

                      child: _isLoadingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Colors.black,
                              size: 22,
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Current location display
          if (!_isSearching)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedPinTitle != null
                            ? 'Showing properties near $_selectedPinTitle'
                            : _currentAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                    ],
                  ),
                ),
                // Clear selection button
                if (_selectedPinLocation != null)
                  GestureDetector(
                    onTap: _clearPinSelection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.clear, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Filter count indicator
                if (_selectedPinLocation == null && _activeFilters.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD98B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: Colors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_activeFilters.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching || _searchController.text.isEmpty) {
      return const SizedBox();
    }

    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2530),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search results for "${_searchController.text}"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_searchResults.length} found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Results list
            if (_isSearching && _searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.white54, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'No locations found',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD98B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getLocationIcon(result.type),
                          color: const Color(0xFFFFD98B),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        _truncateDisplayName(result.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${result.type} • ${result.lat.toStringAsFixed(4)}, ${result.lon.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                      onTap: () => _onLocationSelected(result),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _truncateDisplayName(String fullName) {
    List<String> parts = fullName.split(',');
    if (parts.length > 3) {
      return '${parts[0]}, ${parts[1]}, ${parts[2]}';
    }
    return fullName;
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'city':
      case 'town':
        return Icons.location_city;
      case 'village':
        return Icons.house;
      case 'suburb':
        return Icons.domain;
      case 'road':
      case 'street':
        return Icons.aod;
      case 'commercial':
      case 'industrial':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildFilterRow() {
    if (_isSearching) return const SizedBox();

    final filters = [
      {'label': 'Newly', 'icon': null},
      {'label': 'Trending', 'icon': null},
      {'label': 'Apartments', 'icon': null},
      {'label': 'Villas', 'icon': null},
    ];

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
              selected: selected,
              onPressed: () => _toggleFilter(label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFD98B)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFFFD98B)
                        : Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapArea(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation != null
                  ? latlong.LatLng(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                    )
                  : latlong.LatLng(17.4474, 78.3919),
              zoom: _currentZoom,
              maxZoom: 18,
              minZoom: 10,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _currentZoom = position.zoom!;
                  });
                }
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.real_beez',
                subdomains: const ['a', 'b', 'c'],
              ),

              // Add markers for ALL properties (all 9)
              MarkerLayer(markers: _buildMapMarkers()),
            ],
          ),

          // Search results overlay
          _buildSearchResults(),

          // Status info
          Positioned(
            top: 22,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedPinLocation != null
                    ? '${_filteredListings.length} properties nearby'
                    : '${_listings.length} properties total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Instructions
          if (_selectedPinLocation == null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Tap any pin to see nearby properties',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    // Add ALL property markers (all 9 properties)
    for (final listing in _listings) {
      Color markerColor;
      bool isSelected =
          _selectedPinLocation != null &&
          listing.position.latitude == _selectedPinLocation!.latitude &&
          listing.position.longitude == _selectedPinLocation!.longitude;

      // Determine marker color based on property type
      if (listing.property?.type == 'villa') {
        markerColor = isSelected ? Colors.red : Colors.green;
      } else if (listing.property?.type == 'apartment') {
        markerColor = isSelected ? Colors.red : Colors.blue;
      } else {
        markerColor = isSelected ? Colors.red : Colors.orange;
      }

      markers.add(
        Marker(
          point: latlong.LatLng(
            listing.position.latitude,
            listing.position.longitude,
          ),
          width: isSelected ? 60 : 50,
          height: isSelected ? 60 : 50,
          child: GestureDetector(
            onTap: () => _onPinSelected(listing),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSelected ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: isSelected ? 8 : 4,
                          offset: Offset(0, isSelected ? 4 : 2),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(color: Colors.yellow, width: 2)
                          : null,
                    ),
                    child: Icon(
                      isSelected ? Icons.location_on : Icons.location_pin,
                      color: markerColor,
                      size: isSelected ? 24 : 20,
                    ),
                  ),
                  SizedBox(height: 2),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: markerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'SELECTED',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildListingCard(int index, bool active) {
    final listing = _filteredListings[index];

    // Format price with proper formatting
    final priceInLakhs = listing.property?.price != null
        ? (listing.property!.price / 100000).toStringAsFixed(1)
        : '80';
    final priceInCrores =
        listing.property?.price != null && listing.property!.price >= 10000000
        ? (listing.property!.price / 10000000).toStringAsFixed(1)
        : '1';

    return GestureDetector(
      onTap: () => _navigateToHomeScreen(listing),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: active ? 5 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          border: active ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: title + actions
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          listing.subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  _goldCircleIcon(Icons.favorite_border),
                ],
              ),
            ),

            // Price row + 'New' badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              child: Row(
                children: [
                  if (listing.isNew)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD98B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (listing.isNew) SizedBox(width: 6),
                  Text(
                    'Price Range start from:',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Price value
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
              child: Text(
                '${priceInLakhs} Lakhs - ${priceInCrores} Crs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: _buildPropertyImage(listing),
              ),
            ),

            // Distance indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    _selectedPinLocation != null
                        ? 'Near selected location'
                        : 'Tap to view details',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPropertyImage(_Listing listing) {
    if (listing.property?.images != null &&
        listing.property!.images.isNotEmpty) {
      final firstImage = listing.property!.images.first.toString();
      return Image.asset(
        firstImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image.asset(
      'assets/images/farmland1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _goldCircleIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
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
      backgroundColor: Color(0xFF061021),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD98B)),
                ),
              )
            : Column(
                children: [
                  SizedBox(height: statusBarPadding),
                  _buildTopBar(),
                  if (_selectedPinLocation == null) _buildFilterRow(),
                  _buildMapArea(context),
                  if (!_isSearching)
                    SizedBox(
                      height: bottomCardHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _filteredListings.length,
                        physics: BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _activePage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final active = index == _activePage;
                          return _buildListingCard(index, active);
                        },
                      ),
                    ),
                  if (!_isSearching) SizedBox(height: 8),
                ],
              ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
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
  final Set<String> tags;
  final Property? property;
  const _Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    this.isNew = false,
    this.tags = const {},
    this.property,
  });
}

class MapSearchResult {
  final String displayName;
  final double lat;
  final double lon;
  final String type;

  MapSearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
